select "Customers" as NumberOf, 
count(distinct(CustomerId)) as Total from Customer

union

select "Invoices" as NumberOf, 
count(distinct(InvoiceId)) as Total from Invoice

union

select "Tracks" as NumberOf, 
count(distinct(TrackId)) as Total from Trackd