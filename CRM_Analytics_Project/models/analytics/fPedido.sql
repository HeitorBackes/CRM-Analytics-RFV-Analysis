
{{ config(materialized='table') }}

SELECT
    p.numero_pedido,
    p.numero_linha_pedido,

    -- Chaves Estrangeiras
    c.id_cliente,
    prod.id_produto,

    -- Métricas e Fatos
    p.quantidade_pedida,
    p.preco_unitario,
    p.valor_total_venda,
    p.data_pedido,
    p.status_pedido,
    p.tamanho_negocio,
    p.dias_desde_ultimo_pedido
FROM {{ ref('stg_auto_sales') }} p
LEFT JOIN {{ ref('dCliente') }} c
    ON p.nome_cliente = c.nome_cliente
LEFT JOIN {{ ref('dProduto') }} prod
    ON p.codigo_produto = prod.codigo_produto
