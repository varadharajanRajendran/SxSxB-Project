SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_MES2Preactor_GetOrders_v1]	
AS
	
	DELETE FROM Temp_MES2Preactor
	INSERT INTO Temp_MES2Preactor (PID,OrderID,ProcessType,PlantNo,EntryID,CustomerNo,FGPart,[Quantity])
		SELECT  CASE Pe.[pom_entry_id]
					WHEN Po.[pom_order_id] THEN '1'
					WHEN (Po.[pom_order_id] + '.PanelQuilt1') THEN '2'
					WHEN (Po.[pom_order_id] + '.PanelQuilt2') THEN '2'
					WHEN (Po.[pom_order_id] + '.MCCHL1') THEN '3'

					WHEN (Po.[pom_order_id] + '.THC1') THEN '4'
					WHEN (Po.[pom_order_id] + '.THC2') THEN '4'
					WHEN (Po.[pom_order_id] + '.BHC1') THEN '5'
					WHEN (Po.[pom_order_id] + '.BHC2') THEN '5'
					WHEN (Po.[pom_order_id] + '.CU1') THEN '6'
					WHEN (Po.[pom_order_id] + '.SBCoil1') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil2') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil3') THEN '7'
					WHEN (Po.[pom_order_id] + '.SBCoil4') THEN '7'
				END
			  ,Po.[pom_order_id]
			  ,CASE Pe.[pom_entry_id]
					WHEN Po.[pom_order_id] THEN 'Line'
					WHEN (Po.[pom_order_id] + '.PanelQuilt1') THEN 'Quilter'
					WHEN (Po.[pom_order_id] + '.PanelQuilt2') THEN 'Quilter'
					WHEN (Po.[pom_order_id] + '.MCCHL1') THEN 'MCCH'
					WHEN (Po.[pom_order_id] + '.THC1') THEN 'THC'
					WHEN (Po.[pom_order_id] + '.THC2') THEN 'THC'
					WHEN (Po.[pom_order_id] + '.BHC1') THEN 'BHC'
					WHEN (Po.[pom_order_id] + '.BHC2') THEN 'BHC'
					WHEN (Po.[pom_order_id] + '.CU1') THEN 'CU'
					WHEN (Po.[pom_order_id] + '.SBCoil1') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil2') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil3') THEN 'Coiler'
					WHEN (Po.[pom_order_id] + '.SBCoil4') THEN 'Coiler'
				END
			  ,REPLACE(Po.[plant_name],'.PLN','')
			  ,Pe.[pom_entry_id]
			  ,Po.[pom_customer_order]
			  ,REPLACE(Po.[ppr_name],'PPR_','')
			  ,Pe.initial_qty
		  FROM [SitMesDB].[dbo].[POM_ENTRY] Pe
			INNER JOIN [SitMesDB].[dbo].[POM_ENTRY_STATUS] PeS On PeS.pom_entry_status_pk=Pe.pom_entry_status_pk
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER] Po	ON	Po.pom_order_pk=Pe.pom_order_pk
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
		  WHERE PeS.id IN('Scheduled','Initial','Download')
			AND PoS.id in('Download','Initial','Scheduled')
			AND (Pe.pom_entry_id=Po.pom_order_id
					OR  Pe.pom_entry_id  like'%.BHC1'
					OR  Pe.pom_entry_id  like'%.BHC2'
					OR  Pe.pom_entry_id  like'%.THC1'
					OR  Pe.pom_entry_id  like'%.THC2'
					OR  Pe.pom_entry_id  like'%.MCCHL1'
					OR  Pe.pom_entry_id  like'%.PanelQuilt1'
					OR  Pe.pom_entry_id  like'%.PanelQuilt2'
					OR  Pe.pom_entry_id  like'%.CU1'
					OR  Pe.pom_entry_id  like'%.SBCoil1'
					OR  Pe.pom_entry_id  like'%.SBCoil2'
					OR  Pe.pom_entry_id  like'%.SBCoil3'
					OR  Pe.pom_entry_id  like'%.SBCoil4')
	
	UPDATE Temp_MES2Preactor
		SET EntryID='NULL'		,
			SAPart='NULL'		,	
			SAPartDesc='NULL'
		WHERE ProcessType='Line'
GO
