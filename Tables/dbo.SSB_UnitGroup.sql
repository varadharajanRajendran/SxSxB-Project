CREATE TABLE [dbo].[SSB_UnitGroup]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_UnitGroup] ADD CONSTRAINT [PK_SSB_DocGroup] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
