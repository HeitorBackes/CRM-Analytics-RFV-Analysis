# 🚀 End-to-End CRM Analytics Pipeline: Matriz RFV

Este projeto implementa um pipeline de dados (ELT) de ponta a ponta focado em **CRM Analytics: Matriz RFV** e **Segmentação de Clientes**. O objetivo principal é transformar dados brutos de transações em uma estrutura dimensional otimizada para tomada de decisão e geração de estratégias de marketing direcionadas.

### 📊 Dashboard Interativo (Power BI)  
👉 **[Clique aqui para acessar o Relatório no Power BI](https://app.powerbi.com/groups/me/reports/d2094472-0d71-4d1b-b8ff-311623627d7f/9b58c531da6992784e81?experience=power-bi)**

<br>

---

<br>

## 🎯 O que é a Matriz RFV?  
A **Matriz RFV** é um método de segmentação de clientes com base em 3 fatores:

1. **(R) Recência:** Há quanto tempo o cliente fez a última compra?  
2. **(F) Frequência:** Quantas vezes ele já comprou?  
3. **(V) Valor:** Quanto ele já gastou no total?

Ao pontuar os clientes em cada um desses pilares (geralmente de 1 a 5), cruzamos os dados para mapear grupos específicos de CRM (como clientes VIPs, em risco ou hibernando), permitindo que o time de Growth Marketing crie campanhas personalizadas com maior ROI e menor custo de aquisição.

## 🎯 Inteligência Comercial: Segmentação RFV

Para extrair insights dos dados da base de clientes, foi desenvolvido o modelo `fRFV`, que calcula dentro do Data Warehouse os indicadores de **Recência (R), Frequência (F) e Valor (V)** para os 89 clientes únicos da base.

A segmentação estratégica cruza a pontuação de Recência (R) com a Média entre Frequência e Valor (Média FV), gerando uma matriz de 25 combinações dividida em 10 grupos de CRM.

Uma descrição de cada segmento RFV segundo o portal G4 Business:

* **VIP:** Compraram recentemente, compram com frequência e gastam mais.

* **Clientes fiéis:** gastam bem e com boa frequência. São responsivos a promoções.

* **Fiéis em potencial:** clientes recentes, mas que gastaram um bom dinheiro e já compraram mais de uma vez.

* **Novos clientes:** compraram recentemente, mas não com frequência.

* **Promissores:** compradores recentes, mas que não gastaram muito.

* **Precisam de atenção:** recência, frequência e valor monetário acima da curva, mas podem não ter comprado tão recentemente assim.

* **Quase hibernando:** recência, frequência e valor monetário abaixo da média. Tendem a se perder se não forem reativados.

* **Não pode perder:** fizeram compras grandes e frequentes, mas não voltaram por muito tempo.

* **Em risco:** gastaram bastante dinheiro e compraram com frequência, mas já há bastante tempo. Precisam retornar à base de clientes.

* **Hibernando:** a última compra foi há muito tempo. Gastam pouco e fazem poucos pedidos.

### 💡 Decisão de Arquitetura Híbrida  
O projeto adota uma abordagem moderna de engenharia de dados:  
1. **No BigQuery:** Mantemos o cálculo do status *atual* do RFV consolidado e estático, servindo como uma "única fonte da verdade" performática e pronta para ser consumida por ferramentas de automação e CRM (como disparo de e-mails ou n8n).  
2. **No Power BI:** Os dados fato e dimensão são consumidos para recriar o cálculo dinamicamente com DAX, permitindo que os gestores filtrem períodos específicos do passado e visualizem a evolução histórica dos segmentos ao longo do tempo.

## 📊 Insights & Resultados

Após a execução bem-sucedida do pipeline no dbt, a tabela final de inteligência de CRM (`fRFV`) consolidou os dados transacionais e distribuiu os **89 clientes únicos** da base histórica através da matriz de Recência, Frequência e Valor.

Usei está consulta para visualizar a quantidade de clientes por segmento:

```  
SELECT  
    segmento_crm,  
    COUNT(id_cliente) AS total_clientes,  
    ROUND(COUNT(id_cliente) * 100.0 / SUM(COUNT(id_cliente)) OVER(), 2) AS percentual_total  
FROM `crm-analytics-501214.ecom_analytics.fRFV`  
GROUP BY  
    segmento_crm  
ORDER BY  
    total_clientes DESC;  
```

Abaixo está a distribuição de clientes por segmento gerada pela consulta no Google BigQuery:

| Posição | Segmento CRM | Total de Clientes | Percentual da Base (%) |
| :---: | :--- | :---: | :---: |
| 1 | Hibernando | 16 | 17.98% |
| 2 | Clientes Fiéis | 15 | 16.85% |
| 3 | Com Potencial | 14 | 15.73% |
| 4 | Em Risco | 14 | 15.73% |
| 5 | VIP | 11 | 12.36% |
| 6 | Prestes a Hibernar | 8 | 8.99% |
| 7 | Não Pode Perder | 6 | 6.74% |
| 8 | Precisam de Atenção | 5 | 5.62% |
| **-** | **Total Geral** | **89** | **100.00%** |

---

### 💡 Estratégias de CRM recomendadas por Segmento

O mapeamento gerou três grandes planos de ação para o time de Growth Marketing:

#### 1. Retenção da Receita Core (29,21% da base)  
* **Segmentos:** `VIP` e `Clientes Fiéis` (26 clientes no total).  
* **Cenário:** Clientes que compram com excelente frequência, gastam valores altos e possuem ótima recência. Eles representam quase um terço da carteira e são o motor financeiro e os defensores estáveis do faturamento do negócio.  
* **Ação Recomendada:** Criar um programa de fidelidade fechado (clube de vantagens), oferecer lançamentos com exclusividade antes do mercado e disponibilizar canais de atendimento prioritários para blindá-los contra a concorrência.

#### 2. Estímulo ao Consumo Ativo (21,35% da base)  
* **Segmentos:** `Com Potencial` e `Precisam de Atenção` (19 clientes no total).  
* **Cenário:** Apresentam um ticket médio saudável e histórico de recompra estabelecido, mas o indicador de recência acusa que estão começando a desacelerar o ritmo de visitas ou que têm potencial para comprar mais se estimulados corretamente.  
* **Ação Recomendada:** Campanhas personalizadas baseadas em produtos complementares ao histórico de compras (*Cross-Selling*), combinadas com gatilhos de urgência ou vantagens progressivas (ex: "ganhe mais pontos na próxima compra").

#### 3. Zona de Recuperação Crítica (49,44% da base)  
* **Segmentos:** `Não Pode Perder`, `Em Risco`, `Prestes a Hibernar` e `Hibernando` (44 clientes no total).  
* **Cenário:** Concentra praticamente metade de toda a base ativa de clientes. São contas que já geraram valor histórico relevante para o negócio, mas estão há muito tempo sem interagir com a plataforma, correndo risco iminente de *Churn* definitivo.  
* **Ação Recomendada:** Réguas de reativação automatizadas (via e-mail marketing ou WhatsApp integrado via n8n/Make). O foco deve ser o resgate do relacionamento através de ofertas personalizadas de margem controlada ou cupons agressivos de "Sentimos sua falta".

> 💡 **Nota sobre os dados:** Os segmentos *Novos Clientes* e *Promissores* obtiveram contagem zerada nesta fotografia dos dados brutos. Isso indica que a base de clientes analisada é madura e composta majoritariamente por clientes antigos, reforçando a necessidade de focar esforços em campanhas de reativação e pós-venda, mas também na aquisição de novos clientes.

## 🛠️ Tecnologias e Ferramentas

* **Data Warehouse:** Google Cloud Platform (GCP) - BigQuery
* **Transformação e Modelagem:** dbt (Data Build Tool) Core 1.11
* **Ambiente de Desenvolvimento:** VS Code / Python 3.12 (Ambiente Local)
* **Visualização de Dados:** Power BI (Cálculos dinâmicos em DAX sincronizados com o DW)

---

## 📐 Arquitetura de Dados & Fluxo ELT

O pipeline foi desenvolvido seguindo a arquitetura ELT (Extract, Load, Transform), na qual os dados são inicialmente carregados no Data Warehouse e, em seguida, transformados por meio do dbt.

O projeto segue as melhores práticas de Analytics Engineering, dividindo as transformações em camadas definidas dentro do BigQuery para garantir segurança, performance e governança:

#### 1. Camada Raw (Dados Brutos)  
* `ecom_raw.raw_auto_sales`: Tabela original contendo o histórico de transações, com colunas em formatos inconsistentes (ex: datas como texto) e registros duplicados por cliente.

#### 2. Camada Staging (Preparação e Padronização)  
* `stg_auto_sales` (Materializada como **VIEW**):  
  * Padronização de nomenclatura para *snake_case*.  
  * Tipagem correta dos dados (Casting), incluindo o tratamento do formato de datas via `PARSE_DATE('%d/%m/%Y', ORDERDATE)`.  
  * Isolamento da origem para proteger as camadas seguintes contra mudanças estruturais no sistema produtivo.

#### 3. Camada Analytics (Modelagem Dimensional - Star Schema)  
As tabelas finais foram materializadas como **TABLES** físicas no BigQuery para maximizar a performance de leitura pelas ferramentas de BI:  
* `dCliente`: Dimensão contendo informações únicas de cada cliente. Foi aplicada a técnica analítica `QUALIFY row_number() over (partition by nome_cliente order by data_pedido desc) = 1` para eliminar duplicados e garantir o estado mais recente do cliente na base.  
* `dProduto`: Dimensão com a listagem única de produtos e preços sugeridos (`MSRP`).  
* `fPedido`: Tabela Fato central contendo as métricas quantitativas (quantidade, preços unitários, valores totais) e chaves estrangeiras para conexão com as dimensões.

O fluxo completo dos dados, desde a ingestão da fonte primária até a segmentação final, está representado no diagrama abaixo:

```mermaid
graph TD
    %% Fontes e Ingestão
    A["Kaggle API: Auto Sales Data"] -->|"Script Python / Pandas"| B[("BigQuery Raw:<br>ecom_raw.raw_auto_sales")]

    %% Camada Staging
    B -->|"dbt run / Limpeza & Casting"| C["stg_auto_sales <br><i>(Camada View)</i>"]

    %% Camada Dimensional
    C -->|"QUALIFY + ROW_NUMBER"| D[("dCliente <br><i>Dimensão - Tabela</i>")]
    C -->|"DISTINCT + ROW_NUMBER"| E[("dProduto <br><i>Dimensão - Tabela</i>")]  
    C -->|"Métricas e Chaves Estrangeiras"| F[("fPedido <br><i>Fato - Tabela</i>")]  
      
    %% Relacionamentos Star Schema  
    D -->|id_cliente| F  
    E -->|id_produto| F  
      
    %% Camada Analytics / CRM  
    F -->|Agrupamento por Cliente & PERCENT_RANK | G[(fRFV <br><i>CRM Analytics - Tabela</i>)]  
      
    %% Estilos Visuais  
    style A fill:#005f73,stroke:#333,stroke-width:1px  
    style B fill:#4285F4,stroke:#333,stroke-width:2px,color:#fff  
    style C fill:#FF9900,stroke:#333,stroke-width:1px,color:#000  
    style D fill:#34A853,stroke:#333,stroke-width:2px,color:#fff  
    style E fill:#34A853,stroke:#333,stroke-width:2px,color:#fff  
    style F fill:#EA4335,stroke:#333,stroke-width:2px,color:#fff  
    style G fill:#9B51E0,stroke:#333,stroke-width:2px,color:#fff

  ```

---

## 📂 Estrutura de Pastas do Projeto

Abaixo está a representação da árvore de diretórios do projeto. A organização segue as boas práticas de engenharia de dados, separando as transformações por camadas conceituais (Staging e Analytics):

```text  
CRM_Analytics/
├── CRM_Analytics.ipynb          # Script Python (Pandas) para extração e carga de dados
├── .gitignore                   # Proteção para ocultar chaves de acesso locais (.env)
├── .env                         # Variáveis de ambiente locais (configurações de chaves)
├── credentials.json             # Chave da conta de serviço do Google Cloud (BigQuery)
└── CRM_Analytics_Project/       # Core do dbt para transformações analíticas
    ├── dbt_project.yml          # Configuração global do projeto dbt
    └── models/                  # Camadas de modelagem SQL
        ├── staging/             # Limpeza, casting e padronização dos dados (Views)
        │   ├── stg_auto_sales.sql
        │   └── schema.yml       # Testes de consistência e qualidade de dados
        └── analytics/           # Modelagem dimensional e métricas de CRM (Tabelas)
            ├── dCliente.sql     # Dimensão de clientes tratados
            ├── dProduto.sql     # Dimensão de produtos e preços unificados
            ├── fPedido.sql      # Fato transacional de vendas
            └── fRFV.sql         # Fato analítico com agrupamento de Recência, Frequência e Valor
