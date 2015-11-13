CREATE TABLE [dbo].[SSB_Terminal_Settings]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Terminal_Settings] ADD CONSTRAINT [PK_SSB_Terminal_Settings] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
