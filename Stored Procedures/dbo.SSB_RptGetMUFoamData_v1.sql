SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[SSB_RptGetMUFoamData_v1]		
AS


DECLARE	@tblMUData Table	(	RowId			int	IDENTITY	,
								PartNo			nvarchar(100)	,
								FoamType		int				,
								CompThickness	float			,
								IsStatic		bit				,
								StorageLocation	int				)



DECLARE @startRow	int				,
		@EndRow		int				,
		@SelOrder	nvarchar(20)	,
		@count		int		

INSERT INTO @tblMUData (PartNo)
	SELECT DISTINCT(ml.def_id)	
	FROM [SitMesDB].[dbo].[POM_ORDER] Po
		INNER JOIN [SitMesDB].[dbo].[POM_ENTRY] AS e ON Po.pom_order_pk = e.pom_order_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_SPECIFICATION] AS ms ON e.pom_entry_pk = ms.pom_entry_pk 
		INNER JOIN [SitMesDB].[dbo].[POM_MATERIAL_LIST] AS ml ON ms.pom_material_specification_pk = ml.pom_material_specification_pk
		INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.[DefID]=ml.def_id
		INNER JOIN [SitMesDB].[dbo].[POM_ORDER_STATUS] PoS ON PoS.pom_order_status_pk=Po.pom_order_status_pk
	WHERE PoS.id='Production'
		AND  ms.name='CONSUMED' /* PRODUCED */
		AND e.pom_entry_id like '%.MU%'

UPDATE @tblMUData
	SET FoamType=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo= MMD.DefID
	WHERE PropertyID='FoamType'

UPDATE @tblMUData
	SET CompThickness=CONVERT(float,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='CompThickness'

UPDATE @tblMUData
	SET IsStatic=Convert(bit,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='IsStatic' 

UPDATE @tblMUData
	SET StorageLocation=CONVERT(int,[PValue])
	FROM [SitMesDB].[dbo].[MMwDefVerPrpVals] MMD
	INNER JOIN @tblMUData MUD ON MUD.PartNo=  MMD.DefID
	WHERE PropertyID='LocationAlias'

SELECT	PartNo			,
		CASE(IsStatic)
			WHEN 1 THEN 'Yes'
			WHEN 0 THEN 'No'	
		END as IsStatic	,
		StorageLocation 
FROM @tblMUData
GO
