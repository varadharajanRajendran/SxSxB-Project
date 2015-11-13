SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SSB_Get_BorderRollInfo]	
	@BatchID nvarchar(255),
	@RollGroup	nvarchar(255)
AS

DECLARE @tblOrder	as Table (	RowId			int IDENTITY	,
								OrderID			nvarchar(50)	,
								OrderPK			nvarchar(50)	)

DECLARE @tblEntryBOM as Table	(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									EntryID			nvarchar(50)	,
									itemClass		nvarchar(255)	,
									PartNo			nvarchar(255)	)

DECLARE @tblEntryProperty as Table	(	RowId			int IDENTITY	,
										OrderID			nvarchar(50)	,
										Property		nvarchar(255)	,
										PValue			nvarchar(255)	)
																
DECLARE @tblRollData as Table	(	RowId			int IDENTITY	,
									OrderID			nvarchar(50)	,
									FillGroup		nvarchar(255)	,
									RMTK			nvarchar(50)	,
									RMRF			nvarchar(50)	,
									RMBK			nvarchar(50)	,
									NeedleBar		nvarchar(50)	,
									Pattern			nvarchar(50)	,
									Width		decimal(5,2)		)

SELECT @BatchID ='a904d3fd-f04b-4dc0-af5d-1ff7e9cfd4d0',
	   @RollGroup='BorderGroup'

/*
SELECT CASE (@RollGRoup)
			WHEN 'Ribbon'	THEN 'BorderGroup'
			WHEN 'RibbonCord' THEN 'BorderGroup'
			WHEN 'RibbonStitch'	THEN 'BorderGroup'
			WHEN 'ByPass' THEN 'BorderGroup'
			WHEN 'NLet' THEN 'BorderGroup'
			WHEN 'Handle' THEN 'HandleGroup'
			WHEN 'Gussett' THEN 'HandleGroup'
		END 
SELECT @RollGRoup
*/
INSERT INTO @tblOrder (OrderID	,OrderPK)
	SELECT [pom_order_id]
		  ,[pom_order_pk]
	FROM [SitMesDB].[dbo].[POMV_ORDR_PRP_VAL]
	WHERE pom_custom_fld_name=@RollGroup
		AND pom_cf_value=@BatchID

INSERT INTO @tblEntryBOM(OrderID,EntryID,itemClass,PartNo)
	SELECT o.pom_order_id,e.pom_entry_id,ml.class, ml.def_id
	FROM  @tblOrder Po
		INNER JOIN	[SitMesDB].dbo.POM_ORDER AS o ON o.pom_order_id=Po.OrderID
		INNER JOIN	[SitMesDB].dbo.POM_ENTRY AS e ON o.pom_order_pk = e.pom_order_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_SPECIFICATION AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN	[SitMesDB].dbo.POM_MATERIAL_LIST AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk 
	WHERE ms.name='CONSUMED'
		AND e.pom_entry_id like '%.BorderDecRoll%'

INSERT INTO @tblEntryProperty(OrderID,Property,PValue)
	SELECT  o.OrderID	,
			CONVERT(nvarchar(255),ocf_rt.pom_custom_fld_name),
			CONVERT(nvarchar(50),ocf_val.pom_cf_value)
	FROM  @tblOrder o 
			INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = o.OrderPK
			INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
			INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
		WHERE Pe.[pom_entry_id] like '%.BorderDecRoll%'

INSERT INTO @tblRollData (orderID)
	SELECT OrderID
	FROM @tblOrder

UPDATE @tblRollData
	SET RMTK=Pe.PartNo
	FROM @tblEntryBOM Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.itemClass='RMTK'

UPDATE @tblRollData
	SET RMBK=Pe.PartNo
	FROM @tblEntryBOM Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.itemClass='RMBK'

UPDATE @tblRollData
	SET RMRF=Pe.PartNo
	FROM @tblEntryBOM Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.itemClass='RMRF'

UPDATE @tblRollData
	SET FillGroup=Pe.PValue
	FROM @tblEntryProperty Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.Property='PROD_GroupID'

UPDATE @tblRollData
	SET NeedleBar=Pe.PValue
	FROM @tblEntryProperty Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.Property='PROD_NeedleBar'

UPDATE @tblRollData
	SET Pattern=Pe.PValue
	FROM @tblEntryProperty Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.Property='PROD_BorderPattern'

UPDATE @tblRollData
	SET Width=CONVERT(decimal(5,2),Pe.PValue)
	FROM @tblEntryProperty Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.Property='PROD_BorderWidth'
/*
UPDATE @tblRollData
	SET NletWidth=CONVERT(decimal(5,2),Pe.PValue)
	FROM @tblEntryProperty Pe
		INNER JOIN @tblRollData Po on Po.OrderID=Pe.OrderID
	WHERE Pe.Property='PROD_NletWidth'

*/

SELECT OrderID,
	   FillGroup,
	   Width,
	   RMTK as [Tick],
	   RMRF as [Roll Foam],
	   RMBK as [Backing],
	   NeedleBar as [Needle Bar],
	   Pattern as [Pattern]
FROM @tblRollData

GO
