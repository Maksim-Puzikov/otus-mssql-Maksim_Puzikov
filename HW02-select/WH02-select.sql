/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO:

select StockItemID, StockItemName from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO:

select s.SupplierID, s.SupplierName from Purchasing.Suppliers as s
left join Purchasing.PurchaseOrders as p on s.SupplierID = p.SupplierID
where p.PurchaseOrderID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO:

select 
	o.OrderID, 
	format(o.OrderDate, 'dd.MM.yyyy') as OrderDate, 
	datename(month, o.OrderDate) as Month, 
	DATEPART(quarter, o.OrderDate) as Quarter,
	case 
		when DATEPART(month, o.OrderDate) BETWEEN 1 and 4
		then '1'
		when DATEPART(month, o.OrderDate) BETWEEN 5 and 8
		then '2'
		when DATEPART(month, o.OrderDate) BETWEEN 9 and 12
		then '3'
		end as 'Third of the year',
		c.CustomerName as Customer
from Sales.Orders as o
join Sales.OrderLines as ol on o.OrderID = ol.OrderID
join Sales.Customers as c on o.CustomerID = c. CustomerID
	where ol.UnitPrice > 100 or (ol.Quantity >20 and ol.PickingCompletedWhen is not null)
order by Quarter, [Third of the year], OrderDate;

--Вариант с постраничной выборкой

select 
	o.OrderID, 
	format(o.OrderDate, 'dd.MM.yyyy') as OrderDate, 
	datename(month, o.OrderDate) as Month, 
	DATEPART(quarter, o.OrderDate) as Quarter,
	case 
		when DATEPART(month, o.OrderDate) BETWEEN 1 and 4
		then '1'
		when DATEPART(month, o.OrderDate) BETWEEN 5 and 8
		then '2'
		when DATEPART(month, o.OrderDate) BETWEEN 9 and 12
		then '3'
		end as 'Third of the year',
		c.CustomerName as Customer
from Sales.Orders as o
join Sales.OrderLines as ol on o.OrderID = ol.OrderID
join Sales.Customers as c on o.CustomerID = c. CustomerID
	where ol.UnitPrice > 100 or (ol.Quantity >20 and ol.PickingCompletedWhen is not null)
order by Quarter, [Third of the year], OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY
	
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO:

select ad.DeliveryMethodName, pp.ExpectedDeliveryDate, ps.SupplierName, ap.FullName from Purchasing.PurchaseOrders as pp
join Application.DeliveryMethods as ad on pp.DeliveryMethodID = ad.DeliveryMethodID
join Purchasing.Suppliers as ps on pp.SupplierID = ps.SupplierID
join Application.People as ap on pp.ContactPersonID = ap.PersonID
where pp.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31' 
and (ad.DeliveryMethodName = 'Air Freight' or ad.DeliveryMethodName = 'Refrigerated Air Freight') 
and pp.IsOrderFinalized > 0

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO:

select top 10
so.OrderID, so.OrderDate, sc.CustomerName, ap.FullName from Sales.Orders as so
join Sales.Customers as sc on so.CustomerID = sc.CustomerID
join Application.People as ap on so.SalespersonPersonID = ap.PersonID
order by so.OrderID desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO:

select sc.Customerid, sc.CustomerName, sc.PhoneNumber  from Sales.Orders as so
join Sales.OrderLines as sol on so.orderid = sol.orderid
join Warehouse.StockItems as ws on sol.StockItemid = ws.StockItemid
join Sales.Customers as sc on sc.customerid = so.customerid
where ws.StockItemName like 'Chocolate frogs 250g'
