## 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/                           # Raw datasets (ERP and CRM data)
│
├── docs/                               # Project documentation
│   ├── etl.drawio                      # ETL techniques and methods
│   ├── data_architecture.drawio        # Project's architecture
│   ├── data_catalog.md                 # Metadata and field descriptions
│   ├── data_flow.drawio                # Data flow diagram
│   ├── data_models.drawio              # Star schema models
│   └── naming-conventions.md           # Naming guidelines
│
├── scripts/                            # SQL scripts
│   ├── bronze/                         # Extraction and loading
│   ├── silver/                         # Cleaning and transformation
│   └── gold/                           # Analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview
├── LICENSE                             # License information
├── .gitignore                          # Files ignored by Git
└── requirements.txt                    # Project dependencies
