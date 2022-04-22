/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

insert into Sales.Customers (
[CustomerID]
,[CustomerName]
,[BillToCustomerID]
,[CustomerCategoryID]
,[BuyingGroupID]
,[PrimaryContactPersonID]
,[AlternateContactPersonID]
,[DeliveryMethodID]
,[DeliveryCityID]
,[PostalCityID]
,[CreditLimit]
,[AccountOpenedDate]
,[StandardDiscountPercentage]
,[IsStatementSent]
,[IsOnCreditHold]
,[PaymentDays]
,[PhoneNumber]
,[FaxNumber]
,[DeliveryRun]
,[RunPosition]
,[WebsiteURL]
,[DeliveryAddressLine1]
,[DeliveryAddressLine2]
,[DeliveryPostalCode]
,[DeliveryLocation]
,[PostalAddressLine1]
,[PostalAddressLine2]
,[PostalPostalCode]
,[LastEditedBy])
values
	(NEXT VALUE FOR Sequences.[CustomerID],'user1',	1,3,1,1001,1002,3,19586,19586,1601.00,'2015-02-12',0.000,0,0,7,'(211)555-0100','(211)555-0100',' ',' ','http://www.tailspintoys1.com','shop 31','431 raunt lane',90298,0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,'PO Box 571','Booseville',90298,1), 
	(NEXT VALUE FOR Sequences.[CustomerID],'user2',	1,3,1,1001,1002,3,19586,19586,1602.00,'2015-02-13',0.000,0,0,7,'(212)555-0100','(212)555-0100',' ',' ','http://www.tailspintoys2.com','shop 32','432 raunt lane',90298,0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,'PO Box 571','Booseville',90298,1),
	(NEXT VALUE FOR Sequences.[CustomerID],'user3',	1,3,1,1001,1002,3,19586,19586,1603.00,'2015-02-14',0.000,0,0,7,'(213)555-0100','(213)555-0100',' ',' ','http://www.tailspintoys3.com','shop 33','433 raunt lane',90298,0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,'PO Box 571','Booseville',90298,1),
	(NEXT VALUE FOR Sequences.[CustomerID],'user4',	1,3,1,1001,1002,3,19586,19586,1604.00,'2015-02-15',0.000,0,0,7,'(214)555-0100','(214)555-0100',' ',' ','http://www.tailspintoys4.com','shop 34','434 raunt lane',90298,0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,'PO Box 571','Booseville',90298,1),
	(NEXT VALUE FOR Sequences.[CustomerID],'user5',	1,3,1,1001,1002,3,19586,19586,1605.00,'2015-02-16',0.000,0,0,7,'(215)555-0100','(215)555-0100',' ',' ','http://www.tailspintoys5.com','shop 35','435 raunt lane',90298,0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,'PO Box 571','Booseville',90298,1);

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

Delete from Sales.Customers
where CustomerID = 1071

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update Sales.Customers
set [CustomerName] = 'user555'
where [CustomerID] = 1073

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

merge Sales.Customers as T1 using Sales.Customers_COPY as T2 on T1.[CustomerName] = T2.[CustomerName]
WHEN MATCHED then update set
[CustomerName]				 =T2.[CustomerName]				 
,[BillToCustomerID]			 =T2.[BillToCustomerID]			 
,[CustomerCategoryID]			 =T2.[CustomerCategoryID]			 
,[BuyingGroupID]				 =T2.[BuyingGroupID]
,[PrimaryContactPersonID]   = T2.[PrimaryContactPersonID] 
,[AlternateContactPersonID] = T2.[AlternateContactPersonID]
,[DeliveryMethodID]			 =T2.[DeliveryMethodID]			 
,[DeliveryCityID]				 =T2.[DeliveryCityID]				 
,[PostalCityID]				 =T2.[PostalCityID]				 
,[CreditLimit]				 =T2.[CreditLimit]				 
,[AccountOpenedDate]			 =T2.[AccountOpenedDate]			 
,[StandardDiscountPercentage]	 =T2.[StandardDiscountPercentage]	 
,[IsStatementSent]			 =T2.[IsStatementSent]			 
,[IsOnCreditHold]				 =T2.[IsOnCreditHold]				 
,[PaymentDays]				 =T2.[PaymentDays]				 
,[PhoneNumber]				 =T2.[PhoneNumber]				 
,[FaxNumber]					 =T2.[FaxNumber]					 
,[DeliveryRun]				 =T2.[DeliveryRun]				 
,[RunPosition]				 =T2.[RunPosition]				 
,[WebsiteURL]					 =T2.[WebsiteURL]					 
,[DeliveryAddressLine1]		 =T2.[DeliveryAddressLine1]		 
,[DeliveryAddressLine2]		 =T2.[DeliveryAddressLine2]		 
,[DeliveryPostalCode]			 =T2.[DeliveryPostalCode]			 
,[DeliveryLocation]			 =T2.[DeliveryLocation]			 
,[PostalAddressLine1]			 =T2.[PostalAddressLine1]			 
,[PostalAddressLine2]			 =T2.[PostalAddressLine2]			 
,[PostalPostalCode]			 =T2.[PostalPostalCode]			 
,[LastEditedBy]				 =T2.[LastEditedBy]				 
WHEN NOT MATCHED THEN INSERT (
[CustomerID]
,[CustomerName]
,[BillToCustomerID]
,[CustomerCategoryID]
,[BuyingGroupID]
,[PrimaryContactPersonID]
,[AlternateContactPersonID]
,[DeliveryMethodID]
,[DeliveryCityID]
,[PostalCityID]
,[CreditLimit]
,[AccountOpenedDate]
,[StandardDiscountPercentage]
,[IsStatementSent]
,[IsOnCreditHold]
,[PaymentDays]
,[PhoneNumber]
,[FaxNumber]
,[DeliveryRun]
,[RunPosition]
,[WebsiteURL]
,[DeliveryAddressLine1]
,[DeliveryAddressLine2]
,[DeliveryPostalCode]
,[DeliveryLocation]
,[PostalAddressLine1]
,[PostalAddressLine2]
,[PostalPostalCode]
,[LastEditedBy])
values (
T2.[CustomerID]
,T2.[CustomerName]
,T2.[BillToCustomerID]
,T2.[CustomerCategoryID]
,T2.[BuyingGroupID]
,T2.[PrimaryContactPersonID]
,T2.[AlternateContactPersonID]
,T2.[DeliveryMethodID]
,T2.[DeliveryCityID]
,T2.[PostalCityID]
,T2.[CreditLimit]
,T2.[AccountOpenedDate]
,T2.[StandardDiscountPercentage]
,T2.[IsStatementSent]
,T2.[IsOnCreditHold]
,T2.[PaymentDays]
,T2.[PhoneNumber]
,T2.[FaxNumber]
,T2.[DeliveryRun]
,T2.[RunPosition]
,T2.[WebsiteURL]
,T2.[DeliveryAddressLine1]
,T2.[DeliveryAddressLine2]
,T2.[DeliveryPostalCode]
,T2.[DeliveryLocation]
,T2.[PostalAddressLine1]
,T2.[PostalAddressLine2]
,T2.[PostalPostalCode]
,T2.[LastEditedBy]);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\SQL Server\1\InvoiceLines15.txt" -T -w -t"@eu&$1&" -S DESKTOP-IUL1KS7\SQL2017'

BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines]
				   FROM "D:\SQL Server\1\InvoiceLines15.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@eu&$1&',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

