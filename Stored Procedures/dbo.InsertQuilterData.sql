SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[InsertQuilterData]
	-- Add the parameters for the stored procedure here
@OrderNo nvarchar,
@ProcessType nvarchar,
@PlantNo nvarchar,
@CustomerName nvarchar,
@CustomerOrderNo nvarchar,@CustomerOrderLineNo nvarchar,
@TruckID nvarchar,@StopID nvarchar,@DueDate Date,@Quantity int,@FGPart nvarchar,@FGPartDesc nvarchar,
@BedSize nvarchar(10),@Width real,@Length real,@ItemClass nvarchar(30),
@ProductType nvarchar(30),@BorderType nvarchar(30),@CoreType nvarchar(30),@NumberOfMULayers nvarchar(30),@PanelType nvarchar(50),
@SAPart nvarchar(30), @SAPartDesc nvarchar(255),@EntryID nvarchar(255),@QuiltNeedleSetting nvarchar(30),@QuiltPatternCAM nvarchar(30),
@QuiltTick nvarchar(14),@QuiltBacking nvarchar(14), @QuiltLayer1 nvarchar(14),@QuiltLayer2 nvarchar(14),@QuiltLayer3 nvarchar(14),@QuiltLayer4 nvarchar(14),
@QuiltLayer5 nvarchar(14),@QuiltLayer6 nvarchar(14)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

insert into SSB_MES2Preactor
(OrderNo,ProcessType,PlantNo,CustomerName,CustomerOrderNo,CustomerOrderLineNo,
TruckID,StopID,DueDate,Quantity,FGPart,FGPartDesc,BedSize,Width,Length,ItemClass,
ProductType,BorderType,CoreType,NumberOfMULayers,PanelType,
SAPart,SAPartDesc,EntryID,QuiltNeedleSetting,QuiltPatternCAM,QuiltTick,QuiltBacking,
QuiltLayer1,QuiltLayer2,QuiltLayer3,QuiltLayer4,
QuiltLayer5,QuiltLayer6)
values(@OrderNo,@ProcessType,@PlantNo,@CustomerName,@CustomerOrderNo,@CustomerOrderLineNo,
@TruckID,@StopID,@DueDate,@Quantity,@FGPart,@FGPartDesc,@BedSize,@Width,@Length,@ItemClass,
@ProductType,@BorderType,@CoreType,@NumberOfMULayers,@PanelType,
@SAPart,@SAPartDesc,@EntryID,@QuiltNeedleSetting,@QuiltPatternCAM,@QuiltTick,@QuiltBacking,
@QuiltLayer1,@QuiltLayer2,@QuiltLayer3,@QuiltLayer4,
@QuiltLayer5,@QuiltLayer6)
END
GO
