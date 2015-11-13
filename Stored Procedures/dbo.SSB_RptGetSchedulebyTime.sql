SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RptGetSchedulebyTime]		
 AS

 DECLARE @tblOrder as table (	rowid			int identity(1,1)	,
								OrderId			nvarchar(50)		,
								EstDateTime		datetime			,
								BHCEstEndTime	dateTime			,
								PQEstEndTime	dateTime			,
								THCEstEndTime	dateTime			,
								SKU				nvarchar(50)		,
								SKUDesc			nvarchar(200)		)	


DECLARE @tblEstTime as Table (  RowID			int identity(1,1) ,
								OrderID			nvarchar(50)	  ,
								EstDateTime		datetime	  )

INSERT INTO @tblEstTime (OrderID,EstDateTime)	
	SELECT Po.Pom_order_id , MAX( DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time]))
	FROM [SitMesDB].[dbo].POM_ORDER AS  Po  
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE (	Pe.Pom_entry_id like '%.BHC%' OR 
			Pe.Pom_entry_id like '%.PanelQuilt%' OR 
			Pe.Pom_entry_id like '%.THC%' )
		AND Pos.id='PreProduction'		
	GROUP BY Po.Pom_order_id

INSERT INTO @tblOrder(OrderId	,EstDateTime,SKU,SKUDesc)
	SELECT OrderID, Est.EstDateTime	, Pe.matl_def_id,  MM.Descript    
	FROM @tblEstTime Est
		INNER JOIN [SitMesDB].dbo.POM_Order Po ON Po.pom_order_id=Est.OrderID
		INNER JOIN	[SitMesDB].dbo.POM_Entry Pe  On Pe.Pom_entry_id=Po.Pom_Order_id
		INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=Pe.matl_def_id 
	ORDER BY Est.EstDateTime ASC

UPDATE @tblOrder
	SET BHCEstEndTime=DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time])
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po  ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE 	Pe.Pom_entry_id like '%.BHC%' 

UPDATE @tblOrder
	SET PQEstEndTime=DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time])
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po  ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE 	Pe.Pom_entry_id like '%.PanelQuilt%' 

UPDATE @tblOrder
	SET THCEstEndTime=DATEADD(minute,-Pe.[estimated_end_time_bias],Pe.[estimated_end_time])
	FROM @tblOrder o
		INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po  ON Po.Pom_order_id=o.OrderId
		INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
	WHERE 	Pe.Pom_entry_id like '%.THC%' 		
	
SELECT OrderID	,
	   BHCEstEndTime,
	   PQEstEndTime
FROM @tblOrder		
GO
