/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29  | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

;with T1 as (
select DATEPART(yyyy, InvoiceDate) as year, DATEPART(MM, InvoiceDate) as month,
SUM(sil.unitprice * sil.quantity) over 
(partition by DATEPART(yyyy, InvoiceDate), DATEPART(MM, InvoiceDate) 
Order by DATEPART(yyyy, InvoiceDate), DATEPART(MM, InvoiceDate)) as Sum_month
from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on sil.InvoiceID = si.InvoiceID
where si.InvoiceDate >= '2015'),

T2 as (
select distinct year, month, Sum_month from T1),

T3 as (
select year, month, Sum_month, (select SUM(Sum_month) from T2 as TT where TT.year<=T2.year and TT.month<=T2.month ) as [cumulative total] from T2 )

select sil.InvoiceID, si.CustomerID, si.InvoiceDate, T2.Sum_month as [sale amount], T3.[cumulative total] from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on sil.InvoiceID = si.InvoiceID
join T3 on Year(si.InvoiceDate) = T3.year and month(si.InvoiceDate) = T3.month
join T2 on T2.year = T3.year and T2.month = T3.month
order by si.InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

;with T1 as (
select DATEPART(yyyy, InvoiceDate) as year, DATEPART(MM, InvoiceDate) as month,
SUM(sil.unitprice * sil.quantity) over 
(partition by DATEPART(yyyy, InvoiceDate), DATEPART(MM, InvoiceDate) 
Order by DATEPART(yyyy, InvoiceDate), DATEPART(MM, InvoiceDate)) as SUM_month
from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on sil.InvoiceID = si.InvoiceID
where si.InvoiceDate >= '2015'),

T2 as (
select distinct year, month, SUM_month from T1),

T3 as (
select year, month, SUM(SUM_month) over(order by year, month rows unbounded preceding) as [cumulative total] from T2)

select sil.InvoiceID, si.CustomerID, si.InvoiceDate, SUM_month as [sale amount], T3.[cumulative total] from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on sil.InvoiceID = si.InvoiceID
join T3 on Year(si.InvoiceDate) = T3.year and month(si.InvoiceDate) = T3.month
join T2 on T2.year = T3.year and T2.month = T3.month
order by si.InvoiceDate

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;with T1 as (
select distinct si.InvoiceDate, sil.StockItemID, 
Sum(sil.Quantity) over(partition by month(si.InvoiceDate), sil.StockItemID order by month(si.InvoiceDate)) as month_Quant
from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on si.InvoiceID=sil.InvoiceID
where YEAR(si.InvoiceDate) = '2016' ),

T2 as (
Select InvoiceDate, StockItemID, month_Quant, 
RANK() over (partition by month(InvoiceDate) order by InvoiceDate, month_Quant desc) as RANK from T1)

select InvoiceDate, datename(MONTH,InvoiceDate), T2.StockItemID, StockItemName, month_Quant from T2
join [Warehouse].[StockItems] as ws on T2.StockItemID=ws.StockItemID
where RANK = 1 or RANK = 2
order by InvoiceDate


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):  
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново 
* посчитайте общее количество товаров и выведете полем в этом же запросе 
* посчитайте общее количество товаров в зависимости от первой буквы названия товара 
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени) 
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items" 
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select StockItemID, StockItemName, Brand, Unitprice,
RANK() over (partition by left(stockitemname,1) order by stockitemname) as NUM,
(select COUNT(StockItemID) from [Warehouse].[StockItems]) as COUNT,
COUNT(stockitemname) over (order by left(stockitemname,1) RANGE CURRENT ROW) as num_count,
LEAD(StockItemID) over (order by stockitemname) as LEAD_ID,
LAG(StockItemID) over (order by stockitemname) as LAG_ID,
LAG(stockitemname,2,'No items') over (order by stockitemname) as LAG_name,
NTILE(30) over (order by TypicalWeightPerUnit) as GROUPS
from [Warehouse].[StockItems] as ws
order by StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;with t1 as (
select si.invoiceID, si.CustomerID, si.SalespersonPersonID,
si.InvoiceDate, rank() over (partition by si.SalespersonPersonID order by  si.invoiceID desc) as last_ID from [Sales].[Invoices] as si)

select ap.PersonID, ap.FullName, sc.CustomerID, sc.CustomerName, t1.InvoiceDate, sct.TransactionAmount from [Application].[People] as ap
join t1 on t1.SalespersonPersonID = ap.PersonID
join Sales.Customers as sc on t1.CustomerID = sc.CustomerID
join [Sales].[CustomerTransactions] as sct on sct.InvoiceID=t1.InvoiceID
where last_ID = 1

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;with t1 as (
select si.CustomerID, sil.InvoiceID, sil.StockItemID, sil.UnitPrice, si.invoicedate,
DENSE_RANK() over (partition by si.CustomerID order by sil.UnitPrice desc) as rank
from [Sales].[InvoiceLines] as sil
join [Sales].[Invoices]  as si on sil.InvoiceID=si.InvoiceID),

t2 as (
select distinct t1.CustomerID, sc.CustomerName, StockItemID, UnitPrice, invoicedate from t1
join[Sales].[Customers] as sc on sc.CustomerID=t1.CustomerID
where rank = 1 or rank = 2 ),

t3 as (
select CustomerID, CustomerName, StockItemID, UnitPrice, invoicedate,
RANK() over (partition by CustomerID, StockItemID order by invoicedate) as rank2 from t2)

select CustomerID, CustomerName, StockItemID, UnitPrice, invoicedate from t3
where rank2 = 1
order by CustomerID, UnitPrice desc

--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 