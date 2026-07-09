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

calculo_percentil AS (
    SELECT
        id_cliente,
        recencia,
        frequencia,
        valor_total,
        -- A função PERCENT_RANK cria uma nota de 0.0 a 1.0 e dá a MESMA posição para empates
        PERCENT_RANK() OVER (ORDER BY recencia DESC) AS rank_r,
        PERCENT_RANK() OVER (ORDER BY frequencia ASC) AS rank_f,
        PERCENT_RANK() OVER (ORDER BY valor_total ASC) AS rank_v
    FROM metricas_rfv
),

scores_rfv AS (
    SELECT
        id_cliente,
        recencia,
        frequencia,
        valor_total,
        -- Converte a posição percentual nos Quintis de 1 a 5 (igual ao PERCENTILEX.INC do DAX)
        CASE 
            WHEN rank_r <= 0.20 THEN 1 
            WHEN rank_r <= 0.40 THEN 2 
            WHEN rank_r <= 0.60 THEN 3 
            WHEN rank_r <= 0.80 THEN 4 
            ELSE 5 
        END AS r_score,
        
        CASE 
            WHEN rank_f <= 0.20 THEN 1 
            WHEN rank_f <= 0.40 THEN 2 
            WHEN rank_f <= 0.60 THEN 3 
            WHEN rank_f <= 0.80 THEN 4 
            ELSE 5 
        END AS f_score,
        
        CASE 
            WHEN rank_v <= 0.20 THEN 1 
            WHEN rank_v <= 0.40 THEN 2 
            WHEN rank_v <= 0.60 THEN 3 
            WHEN rank_v <= 0.80 THEN 4 
            ELSE 5 
        END AS v_score
    FROM calculo_percentil
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

        -- Aplicação da regra de negócio baseada na Matriz R x Média(FV)
        CASE
            WHEN r_score = 5 AND media_fv IN (4, 5) THEN 'VIP'
            WHEN r_score IN (3, 4) AND media_fv IN (4, 5) THEN 'Clientes Fiéis'
            WHEN r_score IN (4, 5) AND media_fv IN (2, 3) THEN 'Com Potencial'
            WHEN r_score IN (4, 5) AND media_fv = 1 THEN 'Novos Clientes'
            WHEN r_score = 3 AND media_fv = 3 THEN 'Precisam de Atenção'
            WHEN r_score = 3 AND media_fv IN (1, 2) THEN 'Prestes a Hibernar'
            WHEN r_score IN (1, 2) AND media_fv = 5 THEN 'Não Pode Perder'
            WHEN r_score IN (1, 2) AND media_fv IN (3, 4) THEN 'Em Risco'
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
    