SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[SSB_RptGetPOSchedule_v1]		
		@SelOrders				nvarchar(255),
		@ShipmentDate			nvarchar(50)	
			
AS	


/*
DECLARE @ShipmentDate			nvarchar(50)	,
		@SelOrders				nvarchar(255)
SELECT 	@ShipmentDate	= '02-09-2015',
		@SelOrders		='New Orders'
*/
DECLARE	@tblOrder AS Table	(	RowId				int	IDENTITY	,
								OrderNo				nvarchar(100)	,
								CoilDesc			nvarchar(200)	)
DECLARE @tblPOProperty as Table(	RowId				int IDENTITY	,
									OrderID				nvarchar(50)	,
									UnitType			nvarchar(50)	,
									TruckID				nvarchar(10)	,
									ShipmentDate		nvarchar(20)	,
									ShipmentTime		nvarchar(20)	,
									SKU					nvarchar(20)	,
									[Description]		nvarchar(255)	,
									[Size]				nvarchar(20)	,
									[BedType]			nvarchar(5)		,
									[CoreType]			nvarchar(10)	,
									[CoilDesc]		    nvarchar(200)	,
									intMUT				nvarchar(5)		,
									intMT				nvarchar(5)		,
									Panel				nvarchar(20)	,	
									BorderDec			nvarchar(20)	,	
									MU					nvarchar(255)	,
									NoofLayers			int				,
									NoofSides			int				,
									L1PartDesc			nvarchar(255)	,
									L2PartDesc			nvarchar(255)	,
									L3PartDesc			nvarchar(255)	,
									L4PartDesc			nvarchar(255)	,
									L5PartDesc			nvarchar(255)	,
									L6PartDesc			nvarchar(255)	,
									intQty				int				)
DECLARE	@tblTruck AS Table	(	RowId				int	IDENTITY	,
								TruckID			nvarchar(100)		,
								ShipmentDate	nvarchar(20)		,
								ShipmentTime	nvarchar(20)		)
DECLARE @tblSKU AS Table	(	RowId				int	IDENTITY	,
								SKU					nvarchar(100)	,
								[Description]		nvarchar(255)	,
								UnitType			nvarchar(50)	,
								[Size]				nvarchar(20)	,
								[BedType]			nvarchar(5)		,
								[CoreType]			nvarchar(10)	,
								Panel				nvarchar(20)	,	
								BorderDec			nvarchar(20)	,	
								MU					nvarchar(255)	,
								NoofLayers			int				,
								NoofSides			int				,
								L1PartDesc			nvarchar(255)	,
								L2PartDesc			nvarchar(255)	,
								L3PartDesc			nvarchar(255)	,
								L4PartDesc			nvarchar(255)	,
								L5PartDesc			nvarchar(255)	,
								L6PartDesc			nvarchar(255)	,
								CoilDesc			nvarchar(200)	)
DECLARE @intStartRow			int				,
		@intEndRow				int				,
		@intStartTruck			int				,
		@intEndTruck			int				,
		@OrderCount				int				,
		@CurrentTruck			nvarchar(50)	,
		@CurrentSKU				nvarchar(50)	,
		@SelOrderStatus			nvarchar(255)	,
		@SelTruck				nvarchar(10)	,
		@SelTruckTime			nvarchar(20)	,
		@SelTruckDate			nvarchar(20)	,
		@TruckTime				nvarchar(MAX)	,
		@TruckDate				nvarchar(MAX)	,
		@TruckID				nvarchar(MAX)	,
		@SQLStringCreateTable	nvarchar(MAX)	,
	    @SQLStringTruckList		nvarchar(MAX)	,
		@SQLStringInsertTime	nvarchar(MAX)	,
	    @SQLStringInsertDate	nvarchar(MAX)	,
		@SQLStringUpdateCount	nvarchar(MAX)	
		
SELECT @SelOrderStatus =CASE @SelOrders
							WHEN 'New Orders' THEN 'Download'
							WHEN 'Manual Line'	 THEN 'Distributed_OHM'
							WHEN 'Automated Line' THEN 'Production'
						END
BEGIN  /* Extract Data */
	IF @SelOrders='New Orders'
	BEGIN
		INSERT INTO @tblOrder (orderNo)
			SELECT (Po.[pom_order_id])
			  FROM [SitMesDB].[dbo].[POM_ORDER] Po
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
			WHERE Pos.id='Production' or Pos.id='Distributed_OHM'	
	END
	ELSE
	BEGIN
		INSERT INTO @tblOrder (orderNo)
		SELECT (Po.[pom_order_id])
		  FROM [SitMesDB].[dbo].[POM_ORDER] Po
			INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
		WHERE Pos.id=@SelOrderStatus
	END
	UPDATE @tblOrder
			SET CoilDesc=MM.Descript 
			FROM @tblOrder Po
				INNER JOIN [SitMesDB].dbo.POM_Order AS o ON o.Pom_order_id=Po.OrderNo
				INNER JOIN [SitMesDB].dbo.POM_ENTRY AS e ON e.pom_order_pk=o.pom_order_pk
				INNER JOIN [SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
				INNER JOIN [SitMesDB].dbo.MMDefinitions MM on MM.DefID=ml.def_id
			WHERE ms.name='CONSUMED'
				AND ml.class='RMMU'
	INSERT INTO @tblPOProperty (OrderID,ShipmentDate,CoilDesc	) /* ShipmentDate */
		SELECT  o.OrderNo,CONVERT(nvarchar(50),ocf_val.pom_cf_value),o.CoilDesc
			FROM  @tblOrder  AS o 
				INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderNo
				INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
				INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
				INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
				INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.[pom_order_status_pk]=Po.[pom_order_status_pk]
			WHERE ocf_rt.pom_custom_fld_name='ShipmentDate'
				AND ocf_val.pom_cf_value= @ShipmentDate
	UPDATE @tblPOProperty  /* Unit Type */
		SET UnitType		=CONVERT(nvarchar(20),ocf_val.pom_cf_value)
		FROM  @tblPOProperty  AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		WHERE ocf_rt.pom_custom_fld_name='MattressUnitType'
	UPDATE @tblPOProperty  /* TruckID */
		SET TruckID		= CONVERT(nvarchar(20),ocf_val.pom_cf_value)
		FROM  @tblPOProperty  AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		WHERE ocf_rt.pom_custom_fld_name='TruckID'
	UPDATE @tblPOProperty /* Shipment Time */
		SET ShipmentTime		= CONVERT(nvarchar(20),ocf_val.pom_cf_value)
		FROM  @tblPOProperty  AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		WHERE ocf_rt.pom_custom_fld_name='ShipmentTime'
	UPDATE @tblPOProperty  /* SKU and Description */
		SET SKU=Pe.[matl_def_id],
			[Description]=MMD.[Descript]
		FROM @tblPOProperty o
			INNER JOIN [SitMesDB].[dbo].[POM_Order] Po  ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MMD ON MMD.[DefID]=Pe.[matl_def_id]
		WHERE [matl_def_id] is not NULL
	UPDATE @tblPOProperty /* Size */
		SET [Size]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN '10' THEN 'TWIN'
						WHEN '20' THEN 'TWIN XL'
						WHEN '30' THEN 'FULL'
						WHEN '40' THEN 'FULL XL'
						WHEN '50' THEN 'QUEEN'
						WHEN '60' THEN 'KING'
						WHEN '70' THEN 'CAL KING'
						ELSE CONVERT(nvarchar(255),MMBv.PValue)
					END
			FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
				INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
			WHERE MMBv.PropertyID='UnitSize'
	UPDATE @tblPOProperty /* BedType */
		SET [BedType]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN '0' THEN 'TT'
						WHEN '1' THEN 'PT'
						ELSE CONVERT(nvarchar(255),MMBv.PValue)
					END
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='BorderType'
	UPDATE @tblPOProperty /* Mattress Unti Type (INTERNAL) */
		SET [intMUT]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN 'PPKT' THEN 'IWC'
						ELSE CONVERT(nvarchar(255),MMBv.PValue)
					  END
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='MattressUnitType'
	UPDATE @tblPOProperty /* MattressType (INTERNAL) */
		SET [intMT]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN '1' THEN 'FEC'
						WHEN '0' THEN ''
					  END
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='MattressType'
	UPDATE @tblPOProperty /* Core Type */
		SET [CoreType]= CASE [intMT]
			WHEN '' THEN [intMUT] 
			ELSE [intMT] + ' (' + [intMUT] + ')'
		END
	UPDATE @tblPOProperty /* Panel */
		SET [Panel]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN '1' THEN 'Quilt'
						WHEN '0' THEN 'non-Quilt'
					  END
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='PanelType'
	UPDATE @tblPOProperty /* Border Decoration */
		SET [BorderDec]= CONVERT(nvarchar(255),MMBv.PValue)
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='BDType'
	UPDATE @tblPOProperty /* NoofSides*/
		SET [NoofSides]= CONVERT(nvarchar(255),MMBv.PValue)
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='MattressSides'
	UPDATE @tblPOProperty /* NoofLayers	 */
		SET [NoofLayers]= CONVERT(nvarchar(255),MMBv.PValue)
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='NOOFMULAYERS'
	UPDATE @tblPOProperty /* L1 Description */
		SET L1PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L1PNo'
	UPDATE @tblPOProperty  /* L2 Description */
		SET L2PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L2PNo'
	UPDATE @tblPOProperty /* L3 Description */
		SET L3PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L3PNo'
	UPDATE @tblPOProperty  /* L4 Description */
		SET L4PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L4PNo'
	UPDATE @tblPOProperty /* L5 Description */
		SET L5PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L5PNo'
	UPDATE @tblPOProperty  /* L6 Description */
		SET L6PartDesc=MD.[Descript]
		FROM  @tblPOProperty AS o 
			INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=o.OrderID
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
			INNER JOIN [SitMesDB].[dbo].[POMV_PRP_GRP_CFG] PropCfg ON PropCfg.pom_custom_fld_name=ocf_rt.pom_custom_fld_name
			INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=CONVERT(nvarchar(50),ocf_val.pom_cf_value)
		WHERE Pe.[pom_entry_id]=o.OrderID + '.MU1'
			AND CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name)='PROD_L6PNo'
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'FOAM',''),
			L2PartDesc=REPLACE(L2PartDesc,'FOAM',''),
			L3PartDesc=REPLACE(L3PartDesc,'FOAM',''),
			L4PartDesc=REPLACE(L4PartDesc,'FOAM',''),
			L5PartDesc=REPLACE(L5PartDesc,'FOAM',''),
			L6PartDesc=REPLACE(L6PartDesc,'FOAM','')
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'TPR 1',''),
			L2PartDesc=REPLACE(L2PartDesc,'TPR 1',''),
			L3PartDesc=REPLACE(L3PartDesc,'TPR 1',''),
			L4PartDesc=REPLACE(L4PartDesc,'TPR 1',''),
			L5PartDesc=REPLACE(L5PartDesc,'TPR 1',''),
			L6PartDesc=REPLACE(L6PartDesc,'TPR 1','')
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'TPR REG 1',''),
			L2PartDesc=REPLACE(L2PartDesc,'TPR REG 1',''),
			L3PartDesc=REPLACE(L3PartDesc,'TPR REG 1',''),
			L4PartDesc=REPLACE(L4PartDesc,'TPR REG 1',''),
			L5PartDesc=REPLACE(L5PartDesc,'TPR REG 1',''),
			L6PartDesc=REPLACE(L6PartDesc,'TPR REG 1','')
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'*',''),
			L2PartDesc=REPLACE(L2PartDesc,'*',''),
			L3PartDesc=REPLACE(L3PartDesc,'*',''),
			L4PartDesc=REPLACE(L4PartDesc,'*',''),
			L5PartDesc=REPLACE(L5PartDesc,'*',''),
			L6PartDesc=REPLACE(L6PartDesc,'*','')
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'TOPPER',''),
			L2PartDesc=REPLACE(L2PartDesc,'TOPPER',''),
			L3PartDesc=REPLACE(L3PartDesc,'TOPPER',''),
			L4PartDesc=REPLACE(L4PartDesc,'TOPPER',''),
			L5PartDesc=REPLACE(L5PartDesc,'TOPPER',''),
			L6PartDesc=REPLACE(L6PartDesc,'TOPPER','')
	UPDATE @tblPOProperty  /* String Manuplation */
		SET L1PartDesc=REPLACE(L1PartDesc,'"',''),
			L2PartDesc=REPLACE(L2PartDesc,'"',''),
			L3PartDesc=REPLACE(L3PartDesc,'"',''),
			L4PartDesc=REPLACE(L4PartDesc,'"',''),
			L5PartDesc=REPLACE(L5PartDesc,'"',''),
			L6PartDesc=REPLACE(L6PartDesc,'"','')
	UPDATE @tblPOProperty /* MU */
		SET [MU]= CASE CONVERT(nvarchar(255),MMBv.PValue)
						WHEN '0' THEN 'Pass through'
						WHEN '1' THEN L1PartDesc
						WHEN '2' THEN L1PartDesc + '  /  ' + L2PartDesc 
						WHEN '3' THEN L1PartDesc + '  /  ' + L2PartDesc + '  /  ' + L3PartDesc
						WHEN '4' THEN L1PartDesc + '  /  ' + L2PartDesc + '  /  ' + L3PartDesc  + '  /  ' + L4PartDesc 
						WHEN '5' THEN L1PartDesc + '  /  ' + L2PartDesc + '  /  ' + L3PartDesc  + '  /  ' + L4PartDesc + '  /  ' + L5PartDesc
						WHEN '6' THEN L1PartDesc + '  /  ' + L2PartDesc + '  /  ' + L3PartDesc  + '  /  ' + L4PartDesc + '  /  ' + L5PartDesc + '  /  ' + L6PartDesc
					  END
		FROM [SitMesDB].[dbo].[MMvdBomAltPrpVals] MMBv
			INNER JOIN @tblPOProperty S ON S.SKU=MMBv.DefID
		WHERE MMBv.PropertyID='NOOFMULAYERS'
	INSERT INTO @tblTruck (TruckID,ShipmentDate,ShipmentTime)
		SELECT DISTINCT TruckID,ShipmentDate,ShipmentTime
		FROM  @tblPOProperty
	INSERT INTO @tblSKU (SKU	,[Description]	,UnitType,[Size],[BedType],[CoreType],Panel	,BorderDec	,MU	,NoofLayers,NoofSides,L1PartDesc,L2PartDesc,L3PartDesc	,L4PartDesc	,L5PartDesc	,L6PartDesc,CoilDesc)
		SELECT DISTINCT SKU	,[Description]	,UnitType,[Size],[BedType],[CoreType],Panel	,BorderDec	,MU	,NoofLayers,NoofSides,L1PartDesc,L2PartDesc,L3PartDesc	,L4PartDesc	,L5PartDesc	,L6PartDesc,CoilDesc		
		FROM  @tblPOProperty
END
SELECT @OrderCount=COUNT(RowID) FROM @tblPOProperty
IF 	@OrderCount>0
BEGIN
	BEGIN /* Create Data Table Insert SKUs */
		SELECT	@intStartTruck =Min(RowID),
				@intEndTruck  =Max(RowID)
		FROM @tblTruck
		IF @intStartTruck>0
		BEGIN
			IF OBJECT_ID('[SSB].[dbo].[POSchedule]') IS NOT NULL
			BEGIN
				DROP TABLE [SSB].[dbo].[POSchedule]
			END
		END
		SELECT @SQLStringTruckList	='',
				@TruckTime			='',
				@TruckDate			='',
				@TruckID				=''
		WHILE @intStartTruck<=@intEndTruck
		BEGIN
			SELECT	@CurrentTruck=TruckID  +  '_' + CONVERT(nvarchar(5),@intStartTruck)  ,
					@SelTruckTime=ShipmentTime	,
					@SelTruckDate=ShipmentDate	
			FROM @tblTruck 
			WHERE RowID=@intStartTruck
			SELECT @SQLStringTruckList=@SQLStringTruckList + '[' + @CurrentTruck +'] nvarchar(20) NULL,'
			SELECT @TruckTime	=@TruckTime	 + ','  + CONVERT(nvarchar(20), char(39) + @SelTruckTime+ char(39))
			SELECT @TruckDate	=@TruckDate	 + ','  + CONVERT(nvarchar(20),+ char(39) +@SelTruckDate + char(39))
			SELECT @TruckID		=@TruckID	 + ',['  + @CurrentTruck + ']'
			SELECT @intStartTruck=@intStartTruck +1 
		END

		
		SET @SQLStringCreateTable = 'CREATE TABLE [SSB].[dbo].[POSchedule]
								(	[RowID] [int] IDENTITY(1,1) NOT NULL,
									[SKU] [nvarchar](20) NULL,
									[Description] [nvarchar](255) NULL,
									[UnitType] [nvarchar](255) NULL,
									[Size] [nvarchar](20) NULL,
									[BedType] [nvarchar](5) NULL,
									[CoreType] [nvarchar](10) NULL,
									[Panel] [nvarchar](20) NULL,
									[BorderDec] [nvarchar](20) NULL,
									[MU] [nvarchar](255) NULL,
									[NoofSides] [int] NULL,
									[CoilDesc]  [nvarchar](255) NULL,
									[Qty] [int] NULL,' + 
									@SQLStringTruckList + '
									[Total] [int] NULL)'
		EXEC (@SQLStringCreateTable)
		SELECT @TruckID=SUBSTRING(@TruckID,2,Len(@TruckID))
		SELECT @TruckDate=SUBSTRING(@TruckDate,2,Len(@TruckDate))
		SELECT @TruckTime=SUBSTRING(@TruckTime,2,Len(@TruckTime))
		SET @SQLStringInsertDate ='INSERT INTO [SSB].[dbo].[POSchedule] ([SKU],' + @TruckID + ') VALUES ( ' + char(39) + 'ShipmentDate' + char(39) + ',' + @TruckDate + ')'
		EXEC (@SQLStringInsertDate)
		SET  @SQLStringInsertTime ='INSERT INTO [SSB].[dbo].[POSchedule] ([SKU],' + @TruckID + ') VALUES ( ' + char(39) + 'ShipmentTime' + char(39) + ',' + @TruckTime + ')'
		EXEC (@SQLStringInsertTime)
		INSERT INTO [SSB].[dbo].[POSchedule] (	SKU,
												[Description]	,
												UnitType		,
												[Size]			,
												[BedType]		,
												[CoreType]		,
												Panel			,
												BorderDec		,
												MU				,
												NoofSides		,
												[CoilDesc]		)
									SELECT   SKU			,
											[Description]	,
											UnitType		,
											[Size]			,
											[BedType]		,
											[CoreType]		,
											Panel			,
											BorderDec		,
											MU				,
											NoofSides		,
											CoilDesc										
										FROM @tblSKU 
									ORDER BY UnitType
	END
	BEGIN /* Truck Data Manuplation */
		SELECT	@intStartRow		=Min(RowID) +2,
				@intEndRow		=Max(RowID)
		FROM [SSB].[dbo].[POSchedule]
		WHILE @intStartRow<=@intEndRow
		BEGIN
			SELECT @CurrentSKU=SKU
			FROM [SSB].[dbo].[POSchedule]
			WHERE RowID=@intStartRow
			SELECT	@intStartTruck	=Min(RowID),
					@intEndTruck	=Max(RowID)
			FROM @tblTruck
			WHILE @intStartTruck<=@intEndTruck
			BEGIN
				SELECT	@CurrentTruck	=TruckID			,
						@SelTruckTime	=ShipmentTime		,
						@SelTruckDate	=ShipmentDate		
				FROM @tblTruck
				WHERE RowID=@intStartTruck
				
				SELECT @OrderCount	= COUNT(RowID) FROM @tblPOProperty
				WHERE TruckID=@CurrentTruck
					AND ShipmentDate=@SelTruckDate
					AND ShipmentTime=@SelTruckTime
					AND SKU=@CurrentSKU
				SET @SQLStringInsertDate= 'UPDATE [SSB].[dbo].[POSchedule] SET [' + @CurrentTruck  + '_' + CONVERT(nvarchar(5),@intStartTruck) + ']=' + char(39) + CONVERT (nvarchar(20),@OrderCount) + char(39) + '   WHERE SKU= ' + char(39) + @CurrentSKU + char(39) 
				EXEC (@SQLStringInsertDate)
				SELECT @intStartTruck=@intStartTruck +1
			END
			SELECT @intStartRow=@intStartRow +1
		END
END

END
	SELECT * FROM [SSB].[dbo].[POSchedule]



GO
