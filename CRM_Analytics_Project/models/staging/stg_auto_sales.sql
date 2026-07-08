
select
    -- Informações do Pedido
    ORDERNUMBER as numero_pedido,
    ORDERLINENUMBER as numero_linha_pedido,
    QUANTITYORDERED as quantidade_pedida,
    PRICEEACH as preco_unitario,
    SALES as valor_total_venda,
    PARSE_DATE('%d/%m/%Y', ORDERDATE) as data_pedido,
    STATUS as status_pedido,
    DEALSIZE as tamanho_negocio,
    DAYS_SINCE_LASTORDER as dias_desde_ultimo_pedido,

    -- Informações do Produto
    PRODUCTCODE as codigo_produto,
    PRODUCTLINE as linha_produto,
    MSRP as preco_sugerido_msrp,

    -- Informações do Cliente, Contacto e Localização
    CUSTOMERNAME as nome_cliente,
    CONTACTFIRSTNAME as nome_contato,
    CONTACTLASTNAME as sobrenome_contato,
    PHONE as telefone_cliente,
    ADDRESSLINE1 as endereco_linha1,
    CITY as cidade,
    POSTALCODE as codigo_postal,
    COUNTRY as pais
from `crm-analytics-501214`.`ecom_raw`.`raw_auto_sales`
