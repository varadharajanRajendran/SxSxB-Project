CREATE TABLE [dbo].[SSB_MES2Preactor_v1.0]
(
[SID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcessType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PlantNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntryID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerOrderLineNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TruckID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StopID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DueDate] [date] NOT NULL,
[DueTime] [time] NULL,
[Quantity] [int] NOT NULL,
[FGPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FGPartDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SAPart] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SAPartDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BedSize] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Height] [real] NULL,
[Width] [real] NOT NULL,
[Length] [real] NOT NULL,
[ItemClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoreType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PanelType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltNeedleSetting] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltPatternCAM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltTick] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltBacking] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuiltLayer6] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThreadLineColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderTick] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderWidth] [float] NULL,
[BorderLabel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderStitch] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderRibbon] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderHandle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderHandleStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderWire] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilSeries] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoilWireGage] [float] NULL,
[CoilsperRow] [int] NULL,
[CoilQuantity] [float] NULL,
[TotalNoofRows] [int] NULL,
[FEC] [bit] NULL,
[NumberOfMULayers] [int] NULL,
[ActualLine] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WaveGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnitType] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BorderCord] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_MES2Preactor_v1.0] ADD CONSTRAINT [PK_SSB_MES2Preactor] PRIMARY KEY CLUSTERED  ([SID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Mattress Size Description (Full, Std King, Queen)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'BedSize'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Border Type (PT,TT)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'BorderType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Core Type (HMB Make, HMB Buy,OC)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'CoreType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Customer ID (Optional)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'CustomerNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order Line Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'CustomerOrderLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sales Order Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'CustomerOrderNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Dispatch Date', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'DueDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Order Entry ID', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'EntryID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Finished Good/Mattress SKU Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'FGPart'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Finished Good/Mattress SKU Description', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'FGPartDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Item Class (M,QA,BR)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'ItemClass'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility Name', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'PlantNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Product Segment Description (Line, Quilter,Border and Coiler)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'ProcessType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Mattress Type (Foam, Latex, Inner Spring)', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'ProductType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sub Assembly Part Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'SAPart'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sub Assembly Part Descrription', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'SAPartDesc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stop Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'StopID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Truck ID/Number', 'SCHEMA', N'dbo', 'TABLE', N'SSB_MES2Preactor_v1.0', 'COLUMN', N'TruckID'
GO
