
{{ config(materialized='table') }}

WITH base_clientes AS (
    SELECT
        nome_cliente,
        nome_contato,
        sobrenome_contato,
        telefone_cliente,
        endereco_linha1,
        cidade,
        codigo_postal,
        pais
    FROM {{ ref('stg_auto_sales') }}
    -- Garante um registo único por cliente pegando no pedido mais recente
    QUALIFY ROW_NUMBER() OVER (PARTITION BY nome_cliente ORDER BY data_pedido DESC) = 1
)

SELECT
    ROW_NUMBER() OVER (ORDER BY nome_cliente) AS id_cliente,
    nome_cliente,
    nome_contato,
    sobrenome_contato,
    telefone_cliente,
    endereco_linha1,
    cidade,
    codigo_postal,
    pais
FROM base_clientes
