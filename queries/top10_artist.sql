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