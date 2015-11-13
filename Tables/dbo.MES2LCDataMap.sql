CREATE TABLE [dbo].[MES2LCDataMap]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[Catagory] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESFnName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LCFnName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LinkTable] [bit] NULL,
[MESDataType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PLCDataType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PLCSequence] [int] NULL,
[ReportSequence] [int] NULL,
[FindString] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplaceString] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeConversion] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MES2LCDataMap] ADD CONSTRAINT [PK_MES2LCDataMap] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
