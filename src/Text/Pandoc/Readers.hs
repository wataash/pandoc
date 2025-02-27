{-# LANGUAGE Strict #-}
{-# LANGUAGE StrictData #-}

{-# LANGUAGE MonoLocalBinds      #-}
{-# LANGUAGE NoImplicitPrelude   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{- |
   Module      : Text.Pandoc.Readers
   Copyright   : Copyright (C) 2006-2019 John MacFarlane
   License     : GNU GPL, version 2 or above

   Maintainer  : John MacFarlane <jgm@berkeley.edu>
   Stability   : alpha
   Portability : portable

This helper module exports the readers.

Note:  all of the readers assume that the input text has @'\n'@
line endings.  So if you get your input text from a web form,
you should remove @'\r'@ characters using @filter (/='\r')@.

-}

module Text.Pandoc.Readers
  (
    -- * Readers: converting /to/ Pandoc format
    Reader (..)
  , readers
  -- , readDocx
  -- , readOdt
  -- , readMarkdown
  , readCommonMark
  -- , readCreole
  -- , readDokuWiki
  , readMediaWiki
  -- , readVimwiki
  -- , readRST
  -- , readOrg
  -- , readLaTeX
  -- , readHtml
  -- , readJATS
  -- , readTextile
  -- , readDocBook
  -- , readOPML
  -- , readHaddock
  -- , readNative
  -- , readJSON
  -- , readTWiki
  -- , readTikiWiki
  -- , readTxt2Tags
  -- , readEPUB
  -- , readMuse
  -- , readFB2
  -- , readIpynb
  -- * Miscellaneous
  , getReader
  , getDefaultExtensions
  ) where

import Prelude
-- import Control.Monad.Except (throwError)
-- import Data.Aeson
import qualified Data.ByteString.Lazy as BL
import Data.List (intercalate)
import Data.Text (Text)
import Text.Pandoc.Class
import Text.Pandoc.Definition
-- import Text.Pandoc.Error
import Text.Pandoc.Extensions
import Text.Pandoc.Options
import Text.Pandoc.Readers.CommonMark
-- import Text.Pandoc.Readers.Creole
-- import Text.Pandoc.Readers.DocBook
-- import Text.Pandoc.Readers.Docx
-- import Text.Pandoc.Readers.DokuWiki
-- import Text.Pandoc.Readers.EPUB
-- import Text.Pandoc.Readers.FB2
-- import Text.Pandoc.Readers.Ipynb
-- import Text.Pandoc.Readers.Haddock
-- import Text.Pandoc.Readers.HTML (readHtml)
-- import Text.Pandoc.Readers.JATS (readJATS)
-- import Text.Pandoc.Readers.LaTeX
-- import Text.Pandoc.Readers.Markdown
import Text.Pandoc.Readers.MediaWiki
-- import Text.Pandoc.Readers.Muse
import Text.Pandoc.Readers.Native
-- import Text.Pandoc.Readers.Odt
-- import Text.Pandoc.Readers.OPML
-- import Text.Pandoc.Readers.Org
-- import Text.Pandoc.Readers.RST
-- import Text.Pandoc.Readers.Textile
-- import Text.Pandoc.Readers.TikiWiki
-- import Text.Pandoc.Readers.TWiki
-- import Text.Pandoc.Readers.Txt2Tags
-- import Text.Pandoc.Readers.Vimwiki
-- import Text.Pandoc.Readers.Man
-- import qualified Text.Pandoc.UTF8 as UTF8
import Text.Parsec.Error

data Reader m = TextReader (ReaderOptions -> Text -> m Pandoc)
              | ByteStringReader (ReaderOptions -> BL.ByteString -> m Pandoc)

-- | Association list of formats and readers.
readers :: PandocMonad m => [(String, Reader m)]
readers = [ ("native"       , TextReader readNative)
          --  ,("json"         , TextReader readJSON)
          --  ,("markdown"     , TextReader readMarkdown)
          --  ,("markdown_strict" , TextReader readMarkdown)
          --  ,("markdown_phpextra" , TextReader readMarkdown)
          --  ,("markdown_github" , TextReader readMarkdown)
          --  ,("markdown_mmd",  TextReader readMarkdown)
           ,("commonmark"   , TextReader readCommonMark)
          --  ,("creole"       , TextReader readCreole)
          --  ,("dokuwiki"     , TextReader readDokuWiki)
           ,("gfm"          , TextReader readCommonMark)
          --  ,("rst"          , TextReader readRST)
           ,("mediawiki"    , TextReader readMediaWiki)
           ,("tracwiki"    , TextReader readMediaWiki)
          --  ,("vimwiki"      , TextReader readVimwiki)
          --  ,("docbook"      , TextReader readDocBook)
          --  ,("opml"         , TextReader readOPML)
          --  ,("org"          , TextReader readOrg)
          --  ,("textile"      , TextReader readTextile) -- TODO : textile+lhs
          --  ,("html"         , TextReader readHtml)
          --  ,("jats"         , TextReader readJATS)
          --  ,("latex"        , TextReader readLaTeX)
          --  ,("haddock"      , TextReader readHaddock)
          --  ,("twiki"        , TextReader readTWiki)
          --  ,("tikiwiki"     , TextReader readTikiWiki)
          --  ,("docx"         , ByteStringReader readDocx)
          --  ,("odt"          , ByteStringReader readOdt)
          --  ,("t2t"          , TextReader readTxt2Tags)
          --  ,("epub"         , ByteStringReader readEPUB)
          --  ,("muse"         , TextReader readMuse)
          --  ,("man"          , TextReader readMan)
          --  ,("fb2"          , TextReader readFB2)
          --  ,("ipynb"        , TextReader readIpynb)
           ]

-- | Retrieve reader, extensions based on formatSpec (format+extensions).
getReader :: PandocMonad m => String -> Either String (Reader m, Extensions)
getReader s =
  case parseFormatSpec s of
       Left e  -> Left $ intercalate "\n" [m | Message m <- errorMessages e]
       Right (readerName, setExts) ->
           case lookup readerName readers of
                   Nothing  -> Left $ "Unknown reader: " ++ readerName
                   Just  r  -> Right (r, setExts $
                                        getDefaultExtensions readerName)

-- -- | Read pandoc document from JSON format.
-- readJSON :: PandocMonad m
--          => ReaderOptions -> Text -> m Pandoc
-- readJSON _ t =
--   case eitherDecode' . BL.fromStrict . UTF8.fromText $ t of
--        Right doc -> return doc
--        Left _    -> throwError $ PandocParseError "JSON parse error"
