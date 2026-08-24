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

# 3. Invoices prices dynamic by Customers  
**Query:**   
```sql
select c.FirstName || ' ' || c.LastName as Name,
i.InvoiceId,
i.InvoiceDate,
i.Total,
LAG(Total) over (partition by c.CustomerId order by i.InvoiceDate) as PreTotal,
Total - LAG(Total) over (partition by c.CustomerId order by i.InvoiceDate) as ComparingToLast
from Customer c 
inner join Invoice i on c.CustomerId = i.CustomerId
ORDER BY c.CustomerId, i.InvoiceDate
```
**Result (example):** 

|Name|InvoiceId|InvoiceDate|Total|PreTotal| ComparingToLast |
|----|---------|-----------|-----|--------|-----------------|
|Luís Gonçalves|98|2022-03-11 00:00:00|3.98||                 |
|Luís Gonçalves|121|2022-06-13 00:00:00|3.96|3.98| -0.02           |
|Luís Gonçalves|143|2022-09-15 00:00:00|5.94|3.96| 1.98            |
|Leonie Köhler|1|2021-01-01 00:00:00|1.98||                 |
|Leonie Köhler|12|2021-02-11 00:00:00|13.86|1.98| 11.88           |
|Leonie Köhler|67|2021-10-12 00:00:00|8.91|13.86| -4.95           |
|Leonie Köhler|196|2023-05-19 00:00:00|1.98|8.91| -6.93           |

Result of this query show each customer Invoices trend by comparing each invoice with the previous one.
In the example we can see that the second Leonie Köhler's invoice was bigger than the first on $11.88, but the next invoices prices declined.

# 4. Top-10 Artists with cumulative percent of revenue  
**Query:**   
```sql
with q1 as (select a.ArtistId
,a.Name
,sum(il.UnitPrice * il.Quantity) as Total
from Artist a
left join Album al on al.ArtistId = a.ArtistId
left join Track t on al.AlbumId = t.AlbumId 
left join InvoiceLine il on t.TrackId  = il.TrackId
left join Invoice i on il.InvoiceId  = i.InvoiceId
group by a.ArtistId
		,a.Name
having sum(il.UnitPrice * il.Quantity) is not null)

select *,
sum(Total) over (order by Total desc) as CumSum,
round((sum(Total) over (order by Total desc) / (select sum(UnitPrice * Quantity) from InvoiceLine)) * 100,2) as PercOfRevenue

from q1 
order by Total desc
limit 10
```
**Result (example):** 

|ArtistId|Name| Total  | CumSum |PercOfRevenue|
|--------|----|--------|--------|-------------|
|90|Iron Maiden| 138.6  | 138.6  |5.95|
|150|U2| 105.93 | 244.53 |10.5|
|50|Metallica| 90.09  | 334.62 |14.37|
|22|Led Zeppelin| 86.13  | 420.75 |18.07|
|149|Lost| 81.59  | 502.34 |21.57|
|156|The Office| 49.75  | 552.09 |23.71|
|113|Os Paralamas Do Sucesso| 44.55  | 596.64 |25.62|
|58|Deep Purple| 43.56  | 640.2  |27.49|
|82|Faith No More| 41.58  | 681.78 |29.28|
|81|Eric Clapton| 39.6   | 721.38 |30.98|

The top-10 artists generate 30.98% of total 
revenue, which demonstrates that in this dataset, 
sales are distributed more or less evenly and do not 
fit the Pareto principle (80/20).