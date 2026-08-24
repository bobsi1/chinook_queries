# 1. Overview  
### - Total number of Customers, Invoices and Tracks    
**Query:**   
```sql
select "Customers" as NumberOf,   
count(distinct(CustomerId)) as Total   
from Customer      
union  
select "Invoices" as NumberOf,     
count(distinct(InvoiceId)) as Total   
from Invoice      
union  
select "Tracks" as NumberOf,   
count(distinct(TrackId)) as Total   
from Track
```      
**Result:**   

|NumberOf|Total|
|--------|-----|
|Customers|59|
|Invoices|412|
|Tracks|3503|

This database includes data about 3503 Tracks, 412 Invoices and 59 Customers.
### - Total dynamic by years    
**Query:**   
```sql
select strftime('%Y', InvoiceDate) as Year,
sum(Total) as Total
from Invoice
group by strftime('%Y', InvoiceDate)
order by strftime('%Y', InvoiceDate)
```
**Result:**   

|Year|Total|
|----|-----|
|2021|449.46|
|2022|481.45|
|2023|469.58|
|2024|477.53|
|2025|450.58|

Revenue hovers around $450-480/year and shows no significant growth or decline.

# 2. Top-5 Genres (by revenue) by Countries  
**Query:**   
```sql
with ranked as (select  
 Customer.Country 
, Genre.Name 
, sum(Invoice.Total) as  Total
, ROW_NUMBER() OVER (PARTITION BY Customer.Country ORDER BY sum(Invoice.Total) DESC) as rank
from Invoice 
left join Customer on Invoice.CustomerId = Customer.CustomerId
left join InvoiceLine on Invoice.InvoiceId = InvoiceLine.InvoiceId
left join Track on Track.TrackId = InvoiceLine.TrackId
left join Genre on Track.GenreId = Genre.GenreId
group by Customer.Country, Genre.Name )

select Country
,Name
,Total
from ranked
where rank <= 5
``` 
**Result (for example 2 countries):**   

|Country|Name| Total  |
|-------|----|--------|
|Argentina|Latin| 91.08  |
|Argentina|Rock| 81.18  |
|Argentina|Alternative & Punk| 80.19  |
|Argentina|Metal| 36.63  |
|Argentina|Easy Listening| 27.72  |
|Australia|Rock| 170.28 |
|Australia|Metal| 87.12  |
|Australia|Heavy Metal| 41.58  |
|Australia|Reggae| 17.82  |
|Australia|Blues| 13.86  |

Here we can see that the most popular genre in Argentina is Latin, which generated 91.08 revenue.
And the most in Australia - Rock with 170.28, more than double Argentina's top revenue.
This can be taken into account during the development of the marketing strategy for different countries.