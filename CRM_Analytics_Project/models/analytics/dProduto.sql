
{{ config(materialized='table') }}

WITH base_produtos AS (
    SELECT DISTINCT
        codigo_produto,
        linha_produto,
        preco_sugerido_msrp
    FROM {{ ref('stg_auto_sales') }}
)

SELECT
    -- Criando a Chave Primária Sequencial
    ROW_NUMBER() OVER (ORDER BY codigo_produto) AS id_produto,
    codigo_produto,
    linha_produto,
    preco_sugerido_msrp
FROM base_produtos
