select c.FirstName || ' ' || c.LastName as Name,
i.InvoiceId,
i.InvoiceDate,
i.Total,
LAG(Total) over (partition by c.CustomerId order by i.InvoiceDate) as PreTotal,
Total - LAG(Total) over (partition by c.CustomerId order by i.InvoiceDate) as ComparingToLast
from Customer c 
inner join Invoice i on c.CustomerId = i.CustomerId
ORDER BY c.CustomerId, i.InvoiceDate