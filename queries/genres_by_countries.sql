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


 