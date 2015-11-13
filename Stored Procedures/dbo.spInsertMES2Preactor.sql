SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[spInsertMES2Preactor] 
	-- Add the parameters for the stored procedure here
	@OrderNo varchar(100),
	@ProcessType varchar(100),
	@PlantNo varchar(100),
	@CustomerName varchar(100),
	@CustomerOrderNo varchar(100),
	@CustomerOrderLineNo varchar(100),
	@TruckID varchar(100),
	@StopID varchar(100),
	@DueDate date,
	@DueTime time,
	@Quantity int,
	@FGPart varchar(100),
	@FGPartDesc varchar(100),
	@BedSize varchar(100),
	@Width  real,
	@Length real,
	@ItemClass  nvarchar(50),
	@ProductType  nvarchar(50),
	@BorderType varchar(100),
	@CoreType nvarchar(50),
	@NumberOfMULayers int,
	@PanelType varchar(100),
	@ActualLine varchar(100),
	@WaveGroup varchar(100),
	@SAPart nvarchar(100),
	@SAPartDesc nvarchar(100),
	@EntryID nvarchar(100),
	@QuiltNeedleSetting nvarchar(100),
	@QuiltPatternCAM nvarchar(100),
	@QuiltTick nvarchar(100),
	@QuiltBacking nvarchar(100),
	@QuiltLayer1 nvarchar(100),
	@QuiltLayer2 nvarchar(100),
	@QuiltLayer3 nvarchar(100),
	@QuiltLayer4 nvarchar(100),
	@QuiltLayer5 nvarchar(100),
	@QuiltLayer6 nvarchar(100),
	@UnitType nvarchar(15),
	@CoilsperRow real,
	@TotalNoofRows real,
	@BorderWire nvarchar(100),
	@FEC nvarchar(100),
	@CoilQuantity nvarchar(100),
	@CoilSeries nvarchar(100),
	@CoilWireGage nvarchar(100),
	@BorderTick nvarchar(100),
	@BorderWidth nvarchar(100),
	@BorderLabel nvarchar(100),
	@BorderStitch nvarchar(100),
	@BorderRibbon nvarchar(100),
	@BorderHandle nvarchar(100),
	@BorderHandleStyle nvarchar(100),
	@BorderCord nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into SSB_MES2Preactor
		(
			OrderNo,
			ProcessType,
			PlantNo,
			CustomerName,
			CustomerOrderNo,
			CustomerOrderLineNo,
			TruckID,
			StopID,
			DueDate,
			DueTime,
			Quantity,
			FGPart,
			FGPartDesc,
			BedSize,
			Width,
			Length,
			ItemClass,
			ProductType,
			BorderType,
			CoreType,
			NumberOfMULayers,
			PanelType,
			ActualLine,
			WaveGroup,
			SAPart,
			SAPartDesc,
			EntryID,
			QuiltNeedleSetting,
			QuiltPatternCAM,
			QuiltTick,
			QuiltBacking,
			QuiltLayer1,
			QuiltLayer2,
			QuiltLayer3,
			QuiltLayer4,
			QuiltLayer5,
			QuiltLayer6,
			CoilsperRow,
			TotalNoofRows,
			BorderWire,
			FEC,
			CoilQuantity,
			CoilSeries,
			CoilWireGage,
			BorderTick,
			BorderWidth,
			BorderLabel,
			BorderStitch,
			BorderRibbon,
			BorderHandle,
			BorderHandleStyle,
			UnitType,
			BorderCord
		) 
	values
		(
			@OrderNo,
			@ProcessType,
			@PlantNo,
			@CustomerName,
			@CustomerOrderNo,
			@CustomerOrderLineNo,
			@TruckID,
			@StopID,
			@DueDate,
			@DueTime,
			@Quantity,
			@FGPart,
			@FGPartDesc,
			@BedSize,
			@Width,
			@Length,
			@ItemClass,
			@ProductType,
			@BorderType,
			@CoreType,
			@NumberOfMULayers,
			@PanelType,
			@ActualLine,
			@WaveGroup,
			@SAPart,
			@SAPartDesc,
			@EntryID,
			@QuiltNeedleSetting,
			@QuiltPatternCAM,
			@QuiltTick,
			@QuiltBacking,
			@QuiltLayer1,
			@QuiltLayer2,
			@QuiltLayer3,
			@QuiltLayer4,
			@QuiltLayer5,
			@QuiltLayer6,
			@CoilsperRow,
			@TotalNoofRows ,
			@BorderWire,
			@FEC,
			@CoilQuantity,
			@CoilSeries,
			@CoilWireGage,
			@BorderTick,
			@BorderWidth,
			@BorderLabel,
			@BorderStitch,
			@BorderRibbon,
			@BorderHandle,
			@BorderHandleStyle,
			@UnitType,
			@BorderCord
		)
END
GO