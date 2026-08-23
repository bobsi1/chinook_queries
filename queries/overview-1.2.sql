select strftime('%Y', InvoiceDate) as Year,
sum(Total) as Total
from Invoice
group by strftime('%Y', InvoiceDate)
order by strftime('%Y', InvoiceDate)