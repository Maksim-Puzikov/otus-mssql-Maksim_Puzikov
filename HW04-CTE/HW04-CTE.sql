/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO:

--1)Вложенный запрос
select PersonID, FullName from Application.People
	where IsSalesPerson > 0 and PersonID not in (select distinct SalespersonPersonid from Sales.Invoices
	where InvoiceDate = '2015-07-04')

--2)через With
;with CTE_SP as
(select PersonID from Application.People
	where IsSalesPerson > 0
except
select distinct SalespersonPersonid from Sales.Invoices
	where InvoiceDate = '2015-07-04')

select ap.PersonID, ap.FullName from Application.People as ap
join CTE_SP on ap.PersonID = CTE_SP.PersonID

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO:

--1)Вложенный запрос / I
select ws.StockItemID, ws.StockItemName, ws.UnitPrice from Warehouse.StockItems as ws
	where ws.UnitPrice in (select min(UnitPrice) from Warehouse.StockItems)

	--Вложенный запрос / II
select ws.StockItemID, ws.StockItemName, ws.UnitPrice from Warehouse.StockItems as ws
	where ws.UnitPrice in (select top 1 UnitPrice from Warehouse.StockItems order by UnitPrice)

--2)через With
;with MIN_CTE as	
(select min(UnitPrice) as MIN_P from Warehouse.StockItems)

select ws.StockItemID, ws.StockItemName, ws.UnitPrice from Warehouse.StockItems as ws 
join MIN_CTE on MIN_CTE.MIN_P = ws.UnitPrice

		
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO:

--1)Вложенный запрос
Select * from Sales.Customers
	where CustomerID in (
		select top 5 CustomerID from Sales.CustomerTransactions
		order by TransactionAmount desc)
order by CustomerID

--2)через With
;WITH top5_CTE AS 
(select CustomerID 
from Sales.CustomerTransactions
order by TransactionAmount desc
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY),
unique_CTE as 
(select distinct * from top5_CTE)

select sc.* from Sales.Customers as sc
join unique_CTE on unique_CTE.CustomerID = sc.CustomerID

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO:

;with 
T1 as 
(select distinct OrderID from Sales.OrderLines
	where UnitPrice in (
select top 3 min(UnitPrice) from Sales.OrderLines
group by UnitPrice
order by UnitPrice desc)),

T2 as 
(select distinct T1.OrderID, ap.FullName, si.CustomerID from T1
join Sales.Invoices as si on si.OrderID = T1.OrderID
join Application.People as ap on ap.PersonID = si.PackedByPersonID),

T3 as
(select distinct apci.CityID, apci.CityName, T2.FullName from T2 
join Sales.Customers as sc on T2.CustomerID = sc.CustomerID
join Application.Cities as apci on sc.DeliveryCityID = apci.CityID)

select * from T3
order by CityID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
