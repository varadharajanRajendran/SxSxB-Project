CREATE TABLE [dbo].[SSB_FECLCData]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[PartNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FoamType] [int] NULL,
[CompThickness] [float] NULL,
[StorageLocation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_FECLCData] ADD CONSTRAINT [PK_SSB_FECLCData] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
