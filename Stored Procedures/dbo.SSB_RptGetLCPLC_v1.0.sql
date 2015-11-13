SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSB_RptGetLCPLC_v1.0]		
 AS


EXEC [dbo].[SSB_Update_tblMES2LC]
SELECT 'FEC TYPE'			as 'FEC TYPE'    	,
		LC.[SKU]			as 'SKU'			,
		MD.[Descript]		as 'PRODUCT'		,
		LC.[Seq]			as 'SNO'			,
		LC.[OrderID]		as 'Job_ID'			,
		LC.[UnitSize]		as 'Unit_Size'		,
		LC.[BFLength]		as 'Length'			,
        LC.[BFWidth]		as 'Width'			,
		LC.[BFHeight]		as 'BF_Thick'		,
	    LC.[FECBFPL]		as 'BF_Loc'			,
        LC.[ERWidth]		as 'ER_Width'		,
        LC.[SRWidth]		as 'SR_Width'		,
        LC.[RailHeight]		as 'Rail_Height'	,
		LC.[CoilDia]		as 'Coil_Dia'		,
		LC.[ColumnCount]	as 'Coils_in_Row'	,
		LC.[RowCount]		as 'Coil_Count'		,
		LC.[CoreHeight]		as 'Core_Height'	,
		LC.[NoofMULayers]	as 'MU_Layers'		,
		LC.[L1Type]			as 'L1_Type'		,
        LC.[L1Height]		as 'L1_Thick'		,
		LC.[MUL1PL]			as 'L1_Loc'			,
		LC.[L2Type]			as 'L2_Type'		,
        LC.[L2Height]		as 'L2_Thick'		,
		LC.[MUL2PL]			as 'L2_Loc'			,
		LC.[L3Type]			as 'L3_Type'		,
        LC.[L3Height]		as 'L3_Thick'		,
		LC.[MUL3PL]			as 'L3_Loc'			,
		LC.[L4Type]			as 'L4_Type'		,
        LC.[L4Height]		as 'L4_Thick'		,
		LC.[MUL4PL]			as 'L4_Loc'			,
        LC.[BorderType]    as 'Pillow_Top'		,
	    CONVERT(int,LC.[CoreType]) as 'Coil_Type'	,
		/*CASE(LC.[CoreType])	
			WHEN 'True' THEN '1' 
			ELSE '0'
		END as 'Coil_Type'	,*/
	    LC.[CoilStyle]		as 'Coil_Style'		,
		LC.[TruckID]		as 'TruckID'		,
		LC.[StopLocationID] as 'StopLocationID'	,
		PQ					as 'PanelQuilt'		,
		M2P.[DueDate]		as 'DueDate'		,
        M2P.[DueTime]		as 'DueTime'		
  FROM [SSB].[dbo].[SSB_MES2LC] LC
	INNER JOIN [SitMesDB].[dbo].[MMDefinitions] MD ON MD.DefName=LC.SKU
	INNER JOIN [SSB].[dbo].[SSB_MES2Preactor] M2P ON M2P.[OrderNo]=LC.[OrderID]
	WHERE M2P.ProcessType='Line'
  ORDER BY LC.[Seq] ASC
GO
