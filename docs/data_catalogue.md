# 📚 Data Catalogue

## Gold Layer

The **Gold Layer** represents the final, business-ready layer of the data warehouse. It follows a **Star Schema** design and contains dimension and fact views that are optimized for analytics, reporting, and business intelligence.

The Gold Layer consists of the following objects:

| Object | Type | Purpose |
|---|---|---|
| `gold.dim_customers` | Dimension | Stores enriched customer information |
| `gold.dim_products` | Dimension | Stores product and product attribute information |
| `gold.fact_sales` | Fact | Stores transactional sales data |

---

# 1. `gold.dim_customers`

### Purpose

Stores customer details enriched with demographic and geographic data.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key uniquely identifying each customer record in the dimension table. |
| `customer_id` | INT | Unique numerical identifier assigned to each customer. |
| `customer_number` | NVARCHAR(50) | Alphanumeric identifier representing the customer, used for tracking and referencing. |
| `first_name` | NVARCHAR(50) | The customer's first name, as recorded in the system. |
| `last_name` | NVARCHAR(50) | The customer's last name or family name. |
| `country` | NVARCHAR(50) | The country of residence for the customer. |
| `marital_status` | NVARCHAR(50) | The marital status of the customer, such as Married or Single. |
| `gender` | NVARCHAR(50) | The gender of the customer, such as Male, Female, or n/a. |
| `birthdate` | DATE | The date of birth of the customer, formatted as YYYY-MM-DD. |
| `create_date` | DATE | The date when the customer record was created in the system. |

### Reference

![gold.dim_customers](assets/dim_customers.png)

---

# 2. `gold.dim_products`

### Purpose

Provides information about products and their attributes.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key uniquely identifying each product record in the product dimension table. |
| `product_id` | INT | A unique identifier assigned to the product for internal tracking and referencing. |
| `product_number` | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization or inventory. |
| `product_name` | NVARCHAR(50) | Descriptive name of the product, including key details such as type, color, and size. |
| `category_id` | NVARCHAR(50) | A unique identifier for the product's category, linking it to its high-level classification. |
| `category` | NVARCHAR(50) | The broader classification of the product, such as Bikes or Components. |
| `subcategory` | NVARCHAR(50) | A more detailed classification of the product within the category. |
| `maintenance_required` | NVARCHAR(50) | Indicates whether the product requires maintenance, such as Yes or No. |
| `cost` | INT | The cost or base price of the product, measured in monetary units. |
| `product_line` | NVARCHAR(50) | The specific product line or series to which the product belongs, such as Road or Mountain. |
| `start_date` | DATE | The date when the product became available for sale or use. |

### Reference

![gold.dim_products](assets/dim_products.png)

---

# 3. `gold.fact_sales`

### Purpose

Stores transactional sales data for analytical purposes.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | A unique alphanumeric identifier for each sales order. |
| `product_key` | INT | Surrogate key linking the order to the product dimension table. |
| `customer_key` | INT | Surrogate key linking the order to the customer dimension table. |
| `order_date` | DATE | The date when the order was placed. |
| `shipping_date` | DATE | The date when the order was shipped to the customer. |
| `due_date` | DATE | The date when the order payment was due. |
| `sales_amount` | INT | The total monetary value of the sale for the line item. |
| `quantity` | INT | The number of units of the product ordered for the line item. |
| `price` | INT | The price per unit of the product for the line item. |

### Reference

![gold.fact_sales](assets/fact_sales.png)
