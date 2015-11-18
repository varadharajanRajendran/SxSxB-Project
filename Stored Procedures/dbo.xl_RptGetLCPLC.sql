SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[xl_RptGetLCPLC]		
	@ProdLine	NVARCHAR(20)
 AS

 DECLARE @SQLStringCreatetable NVARCHAR(Max)
 EXEC [SSB].[dbo].[PLC_UtilityGenerateDataSet]
		@ProdLineName		= @ProdLine,
		@StatusID			= 'PreProduction',
		@TransactionType	= 'BC',
		@ResendData			= '0'

SET @SQLStringCreateTable = (' SELECT	ISNULL(LC.FECType,'''')						as ''FEC TYPE''    	,
										LC.[SKUNo]									as ''SKU''			,
										LC.[Product]								as ''PRODUCT''		,	
										LC.[JobID]									as ''Job_ID''		,
										LC.[UnitSize]								as ''Unit_Size''	,
										LC.[Length]									AS ''Length''		,
										LC.[Width]									as ''Width''		,
										ISNULL(LC.[BFThick],0)						as ''BF_Thick''		,
										ISNULL(LC.[BFLOC],0)						as ''BF_Loc''		,
										ISNULL(LC.[SRThick],0)						as ''SR_Width''		,
										ISNULL(LC.[ERThick],0)						as ''ER_Width''		,
										ISNULL(LC.[RailHeight],0)					as ''Rail_Height''	,
										ISNULL(LC.[CoilDia],0)						as ''Coil_Dia''		,
										ISNULL(LC.[NoOfRows],0)					as ''Coils_in_Row''		,
										ISNULL(LC.[RowCount]	,0)					as ''Coil_Count''	,
										ISNULL(LC.[CoreHeight],0)					as ''Core_Height''	,
										ISNULL(LC.[MULayers]	,0)					as ''MU_Layers''	,
										ISNULL(LC.[L1Type]	,0)						as ''L1_Type''		,
										ISNULL(LC.[L1Thickness],0)					as ''L1_Thick''		,
										ISNULL(LC.[L1Loc]		,0)					as ''L1_Loc''		,
										ISNULL(LC.[L2Type]	,0)						as ''L2_Type''		,
										ISNULL(LC.[L2Thickness],0)					as ''L2_Thick''		,
										ISNULL(LC.[L2Loc]		,0)					as ''L2_Loc''		,
										ISNULL(LC.[L3Type]	,0)						as ''L3_Type''		,
										ISNULL(LC.[L3Thickness],0)					as ''L3_Thick''		,
										ISNULL(LC.[L3Loc]	,0)						as ''L3_Loc''		,
										ISNULL(LC.[L4Type]	,0)						as ''L4_Type''		,
										ISNULL(LC.[L4Thickness],0)					as ''L4_Thick''		,
										ISNULL(LC.[L4Loc]		,0)					as ''L4_Loc''		,
										ISNULL(LC.[L5Type]	,0)						as ''L5_Type''		,
										ISNULL(LC.[L5Thickness],0)					as ''L5_Thick''		,
										ISNULL(LC.[L5Loc]	,0)						as ''L5_Loc''		,
										ISNULL(LC.[L6Type]	,0)						as ''L6_Type''		,
										ISNULL(LC.[L6Thickness],0)					as ''L6_Thick''		,
										ISNULL(LC.[L6Loc]		,0)					as ''L6_Loc''		,
										ISNULL(LC.[PillowTop]	,0)					as ''Pillow_Top''	,
										CONVERT(int,ISNULL(LC.[CoilType],0))		as ''Coil_Type''	,
										ISNULL(LC.[CoilStyle]	,0)					as ''Coil_Style''	,
										ISNULL(LC.[TruckID]	,0)						as ''TruckID''		,
										ISNULL(LC.[StopID],0)						as ''StopLocationID'',
										CONVERT(nvarchar(50),ocf_val.pom_cf_value)	as ''UnitType''		,
										CONVERT(nvarchar(50),BAPV.PValue)			as ''MSides''
								  FROM  [SitMesDB].dbo.MMvBomAltPrpVals AS BAPV WITH (NOLOCK) 
									  INNER JOIN  [SitMesDB].dbo.MMBomAlts AS BA WITH (NOLOCK) ON BA.BomAltPK = BAPV.BomAltPK 
									  INNER JOIN  [SitMesDB].dbo.MMBoms AS B WITH (NOLOCK) ON B.BomPK = BA.BomPK 
									  INNER JOIN  [SitMesDB].dbo.MMDefinitions AS D WITH (NOLOCK) ON D.DefPK = B.DefPK 
									  INNER JOIN  [SitMesDB].dbo.MMProperties AS P WITH (NOLOCK) ON P.PropertyPK = BAPV.PropertyPK 
									  INNER JOIN  [SSB].[dbo].[PLC_BC_'+ @ProdLine + '] LC ON LC.SKUNo=D.[DefID]
									  INNER JOIN [SitMesDB].[dbo].POM_ORDER AS  Po ON Po.Pom_order_id=LC.JobID
									  INNER JOIN [SitMesDB].[dbo].POM_ENTRY AS Pe ON Pe.Pom_order_pk = Po.Pom_order_pk 
									  INNER JOIN [SitMesDB].[dbo].POM_CUSTOM_FIELD_RT AS ocf_rt ON Pe.pom_entry_pk = ocf_rt.pom_entry_pk 
									  INNER JOIN [SitMesDB].dbo.POM_CF_VALUE_RT AS ocf_val ON ocf_rt.pom_custom_field_rt_pk = ocf_val.pom_custom_field_rt_pk
								WHERE ocf_rt.pom_custom_fld_name=''MattressUnitType''
									AND P.PropertyID=''MattressSides''			
								  ORDER BY [EstSeq],[JobID]	 ASC')
	EXEC (@SQLStringCreateTable)
GO
