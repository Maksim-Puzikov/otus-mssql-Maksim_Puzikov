/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

;with t1 as (
select CustomerID, CustomerName, CHARINDEX ('(',CustomerName)as x from [Sales].[Customers]
where CustomerID between 2 and 6 ),
t2 as (
select CustomerID, CustomerName, SUBSTRING(CustomerName,x+1,50) as x2 from t1),
t3 as (
select CustomerID, CustomerName, CHARINDEX (')',x2) as x3 from t2),
t4 as (
select t3.CustomerID, left(x2,x3-1) as CustomerName from t3
join t2 on t2.CustomerName = t3.CustomerName),
t5 as (
select CustomerName, Format(DATEADD(month, DATEDIFF(month, 0, InvoiceDate), 0),'dd.MM.yyyy') AS InvoiceMonth, COUNT(InvoiceID) as count_Sale from [Sales].[Invoices] as si
join t4 on t4.CustomerID = si.CustomerID
group by t4.CustomerName, Format(DATEADD(month, DATEDIFF(month, 0, InvoiceDate), 0),'dd.MM.yyyy'))

select InvoiceMonth,
ISNULL([Sylvanite, MT], 0) AS [Sylvanite, MT], 
ISNULL([Peeples Valley, AZ], 0) AS [Peeples Valley, AZ], 
ISNULL([Medicine Lodge, KS], 0) AS [Medicine Lodge, KS], 
ISNULL([Gasport, NY], 0) AS [Gasport, NY], 
ISNULL([Jessie, ND], 0) AS [Jessie, ND]  
from t5 
pivot (sum(count_Sale) for CustomerName in ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])) as pi
order by DATEPART(yyyy,InvoiceMonth), DATEPART(MM,InvoiceMonth)

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

;with t1 as (
select [CustomerName], [DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2] from [Sales].[Customers] as sc
where CustomerName like 'Tailspin Toys%'),
t2 as (
select * from t1
unpivot (AddressLine for [AD] in ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])) as unpiv)

select [CustomerName], AddressLine from t2

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

;with t1 as (
select [CountryID], [CountryName], [IsoAlpha3Code], convert(nvarchar(3),[IsoNumericCode]) as NUM from Application.Countries as ac ),
t2 as (
select * from t1
unpivot (Code for CN in ([IsoAlpha3Code], NUM)) as unpiv)

select [CountryID], [CountryName], code from t2
order by [CountryID]

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;with t1 as(
select distinct CustomerID, UnitPrice from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on si.InvoiceID=sil.InvoiceID ),

t2 as (select TT.* from (
select distinct CustomerID from t1 ) as t11
cross apply (select top 2 * from t1 as t12 where t12.CustomerID=t11.CustomerID order by t12.UnitPrice desc) as TT)

select si.CustomerID, sc.CustomerName, sil.StockItemID, sil.UnitPrice, si.invoicedate from [Sales].[Invoices] as si
join [Sales].[InvoiceLines] as sil on si.InvoiceID=sil.InvoiceID
join t2 on t2.CustomerID=si.CustomerID
join [Sales].[Customers] as sc on sc.CustomerID = t2.CustomerID
where t2.UnitPrice=sil.UnitPrice and t2.CustomerID=si.CustomerID
order by CustomerID, UnitPrice desc

