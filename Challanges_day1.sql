SET search_path TO oe;

--No. 1
select
    c.category_id, c.category_name, 
count(1) as total_product 
from categories c
join products p on c.category_id = p.category_id
group by 1
order by 2

--No. 2
select
    s.supplier_id, s.company_name, 
count(1) as total_product 
from suppliers s
join products p on s.supplier_id = p.supplier_id
group by 1
order by total_product desc

--No. 3
select
    s.supplier_id, s.company_name, 
count(1) as total_product,
to_char(avg(p.unit_price), '99.99') as avg_unit_price
from suppliers s
join products p on s.supplier_id = p.supplier_id
group by 1
order by total_product desc

--No. 4
select p.product_id, product_name, s.supplier_id, s.company_name, 
unit_price, units_in_stock, units_on_order, reorder_level
from products p
join suppliers s on p.supplier_id = s.supplier_id
where p.units_in_stock <= p.reorder_level
order by product_name asc;

--No. 5
select 
k.customer_id, k.company_name,
count(1) as total_order
from customers k
join orders o on o.customer_id=k.customer_id
group by k.customer_id
order by customer_id

--No.6
select o.order_id,o.customer_id,o.order_date,
o.required_date,o.shipped_date,
shipped_date - order_date as delivery_time
from orders o
where shipped_date - order_date > 10

--No.7
select p.product_id,p.product_name,
sum(od.quantity) as total_qty
from products p
join order_details od on p.product_id=od.product_id
group by 1
order by total_qty desc

--No.8
select c.category_id, c.category_name,
sum(od.quantity) as total_qty_ordered
from products p
join categories c on p.category_id=c.category_id
join order_details od on p.product_id=od.product_id
group by c.category_id, c.category_name
order by total_qty_ordered desc

--N0.9 (CTE)
with emps as(
select c.category_id, c.category_name,
sum(od.quantity) as total_qty_ordered
from products p
join categories c on p.category_id=c.category_id
join order_details od on p.product_id=od.product_id
group by c.category_id, c.category_name
order by total_qty_ordered desc)
select * from emps
where total_qty_ordered = (select min(total_qty_ordered)from emps)
or total_qty_ordered = (select max(total_qty_ordered) from emps)

--N0.9 (union)
with emps as(
select c.category_id, c.category_name,
sum(od.quantity) as total_qty_ordered
from products p
join categories c on p.category_id=c.category_id
join order_details od on p.product_id=od.product_id
group by c.category_id, c.category_name)
select * from emps
where total_qty_ordered = (select min(total_qty_ordered)from emps)
union 
select * from emps
where total_qty_ordered = (select max(total_qty_ordered)from emps)

-- No.10 (cte)
with cte1 as(
select s.shipper_id, s.company_name, o.order_id
from shippers s 
join orders o on s.shipper_id= o.ship_via),
cte2 as (
select p.product_id, p.product_name, od.order_id,
sum(od.quantity)as total_qty_ordered
from products p
join order_details od on p.product_id=od.product_id
group by 1, 2, 3)
select c1.shipper_id, c1.company_name, c2.product_id,
c2.product_name,sum(c2.total_qty_ordered) as total_qty_ordered
from cte1 c1 
join cte2 c2 on c1.order_id=c2.order_id
group by 1, 2, 3, 4
order by c1.company_name, c2.product_name 

--No 10 
select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) AS total_qty_ordered
from shippers s
join orders o on s.shipper_id = o.ship_via
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
group by s.shipper_id, s.company_name, p.product_id, p.product_name
order by s.company_name, p.product_name;

--No 11 
with total_per_category AS (
select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) AS total_qty_ordered
from shippers s
join orders o on s.shipper_id = o.ship_via
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
group by p.product_name, s.shipper_id, s.company_name, p.product_id),
ranked as (
  select *, rank() over (partition by company_name order by total_qty_ordered desc) as rank_max,
         rank() over (partition by company_name order by total_qty_ordered asc) as rank_min
  from total_per_category
)
select shipper_id, company_name, product_id, product_name, total_qty_ordered
from ranked
where rank_max = 1 or rank_min = 1
order by shipper_id, total_qty_ordered;

--No 11 (cte)
with cte3 as (
    select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) as total_qty_ordered
    from shippers s
    join orders o on s.shipper_id = o.ship_via
    join order_details od on o.order_id = od.order_id
    join products p on od.product_id = p.product_id
    group by s.shipper_id, s.company_name, p.product_id, p.product_name
    order by s.company_name, p.product_name
),
min_max_per_shipper as (
    select
        shipper_id,
        min(total_qty_ordered) as min_qty,
        max(total_qty_ordered) as max_qty
    from cte3
    group by shipper_id
)
select c.shipper_id, c.company_name, c.product_id, c.product_name, c.total_qty_ordered
from cte3 c
join min_max_per_shipper m on c.shipper_id = m.shipper_id
where c.total_qty_ordered = m.min_qty or c.total_qty_ordered = m.max_qty
order by c.shipper_id asc, c.total_qty_ordered asc;


--No 12
with recursive hirarki as (
	select
	e.employee_id,
	e.first_name||' '||last_name as full_name,
	e.manager_id,
	d.department_name,
	1 as level
	from employees e join departments d on e.department_id=d.department_id 
	where manager_id is null
	
	union all
	
	select
	p.employee_id,
	p.first_name||' '||last_name as full_name,
	p.manager_id,
	d.department_name,
	h.level + 1
	from employees p
	join departments d on p.department_id = d.department_id
	join hirarki h on p.manager_id=h.employee_id
)
select * from hirarki
order by employee_id

