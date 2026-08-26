with recursive employees as (
select e1.EmployeeId , 
e1.FirstName || ' ' || e1.LastName  as Name, 
e1.ReportsTo as ManagerId,
e1.FirstName || ' ' || e1.LastName as Path
from Employee e1
where ReportsTo is  null

union all

select  e2.EmployeeId , 
e2.FirstName || ' ' || e2.LastName as Name, 
e2.ReportsTo  ,
employees.Path || ' -> ' || e2.FirstName || ' ' || e2.LastName as Path
from Employee e2
join employees on employees.EmployeeId = e2.ReportsTo

)
select employees.EmployeeId, employees.Name, employees.Path, count(distinct(CustomerId)) as NumberOfCustomers
from employees
left join employees em2 on em2.Path like employees.Path || '%'
left join Customer on em2.EmployeeId = Customer.SupportRepId
group by  employees.EmployeeId, employees.Name, employees.Path
