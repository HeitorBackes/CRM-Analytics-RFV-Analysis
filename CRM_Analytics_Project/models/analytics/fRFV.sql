
{{ config(materialized='table') }}

WITH dados_base AS (
    SELECT
        id_cliente,
        numero_pedido,
        valor_total_venda,
        dias_desde_ultimo_pedido
    FROM {{ ref('fPedido') }}
),

metricas_rfv AS (
    SELECT
        id_cliente,
        MIN(dias_desde_ultimo_pedido) AS recencia,
        COUNT(DISTINCT numero_pedido) AS frequencia,
        SUM(valor_total_venda) AS valor_total
    FROM dados_base
    GROUP BY id_cliente
),

scores_rfv AS (
    SELECT
        id_cliente,
        recencia,
        frequencia,
        valor_total,
        -- Alterado para NTILE(5) para separar em 5 partes (Quintis)
        NTILE(5) OVER (ORDER BY recencia DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequencia ASC) AS f_score,
        NTILE(5) OVER (ORDER BY valor_total ASC) AS v_score
    FROM metricas_rfv
),

calculo_matriz AS (
    SELECT
        id_cliente,
        recencia,
        frequencia,
        valor_total,
        r_score,
        f_score,
        v_score,
        -- Calcula a média aritmética entre F e V e arredonda para um número inteiro entre 1 e 5
        CAST(ROUND((f_score + v_score) / 2.0) AS INT64) AS media_fv
    FROM scores_rfv
),

segmentacao AS (
    SELECT
        id_cliente,
        recencia,
        frequencia,
        valor_total,
        r_score,
        f_score,
        v_score,
        media_fv,
        -- Cria o código visual da nova matriz (Ex: '5x5', '3x2')
        CONCAT(CAST(r_score AS STRING), 'x', CAST(media_fv AS STRING)) AS codigo_matriz_rfv,

        -- Aplicação da nova regra de negócio baseada na Matriz R x Média(FV)
        CASE
            -- VIP: 5x5 e 5x4
            WHEN r_score = 5 AND media_fv IN (4, 5) THEN 'VIP'

            -- Clientes Fiéis: 3x5, 3x4, 4x5, 4x4
            WHEN r_score IN (3, 4) AND media_fv IN (4, 5) THEN 'Clientes Fiéis'

            -- Com Potencial: 4x3, 4x2, 5x3, 5x2
            WHEN r_score IN (4, 5) AND media_fv IN (2, 3) THEN 'Com Potencial'

            -- Novos Clientes: 5x1, 4x1
            WHEN r_score IN (4, 5) AND media_fv = 1 THEN 'Novos Clientes'

            -- Precisam de Atenção: 3x3
            WHEN r_score = 3 AND media_fv = 3 THEN 'Precisam de Atenção'

            -- Prestes a Hibernar: 3x2, 3x1
            WHEN r_score = 3 AND media_fv IN (1, 2) THEN 'Prestes a Hibernar'

            -- Não Pode Perder: 2x5, 1x5
            WHEN r_score IN (1, 2) AND media_fv = 5 THEN 'Não Pode Perder'

            -- Em Risco: 1x4, 2x4, 1x3 + ajuste do 2x3
            WHEN r_score IN (1, 2) AND media_fv IN (3, 4) THEN 'Em Risco'

            -- Hibernando: 2x2, 2x1, 1x2, 1x1
            WHEN r_score IN (1, 2) AND media_fv IN (1, 2) THEN 'Hibernando'

            ELSE 'Não Classificado'
        END AS segmento_crm
    FROM calculo_matriz
)

SELECT
    s.id_cliente,
    c.nome_cliente,
    s.recencia,
    s.frequencia,
    s.valor_total,
    s.r_score,
    s.f_score,
    s.v_score,
    s.media_fv,
    s.codigo_matriz_rfv,
    s.segmento_crm
FROM segmentacao s
LEFT JOIN {{ ref('dCliente') }} c
    ON s.id_cliente = c.id_cliente
    