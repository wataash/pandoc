{-# LANGUAGE Strict #-}
{-# LANGUAGE StrictData #-}

{-# LANGUAGE NoImplicitPrelude #-}
{- |
   Module      : Text.Pandoc.App.FormatHeuristics
   Copyright   : Copyright (C) 2006-2019 John MacFarlane
   License     : GNU GPL, version 2 or above

   Maintainer  : John MacFarlane <jgm@berkeley@edu>
   Stability   : alpha
   Portability : portable

Guess the format of a file from its name.
-}
module Text.Pandoc.App.FormatHeuristics
  ( formatFromFilePaths
  ) where

import Prelude
import Data.Char (toLower)
import System.FilePath (takeExtension)

-- Determine default format based on file extensions.
formatFromFilePaths :: [FilePath] -> Maybe String
formatFromFilePaths [] = Nothing
formatFromFilePaths (x:xs) =
  case formatFromFilePath x of
    Just f     -> Just f
    Nothing    -> formatFromFilePaths xs

-- Determine format based on file extension
formatFromFilePath :: FilePath -> Maybe String
formatFromFilePath x =
  case takeExtension (map toLower x) of
    ".adoc"     -> Just "asciidoc"
    ".asciidoc" -> Just "asciidoc"
    ".context"  -> Just "context"
    ".ctx"      -> Just "context"
    ".db"       -> Just "docbook"
    ".doc"      -> Just "doc"  -- so we get an "unknown reader" error
    ".docx"     -> Just "docx"
    ".dokuwiki" -> Just "dokuwiki"
    ".epub"     -> Just "epub"
    ".fb2"      -> Just "fb2"
    ".htm"      -> Just "html"
    ".html"     -> Just "html"
    ".icml"     -> Just "icml"
    ".json"     -> Just "json"
    ".latex"    -> Just "latex"
    ".lhs"      -> Just "markdown+lhs"
    ".ltx"      -> Just "latex"
    -- ".markdown" -> Just "markdown"
    ".markdown" -> Just "gfm"
    -- ".md"       -> Just "markdown"
    ".md"       -> Just "gfm"
    ".ms"       -> Just "ms"
    ".muse"     -> Just "muse"
    ".native"   -> Just "native"
    ".odt"      -> Just "odt"
    ".opml"     -> Just "opml"
    ".org"      -> Just "org"
    ".pdf"      -> Just "pdf"  -- so we get an "unknown reader" error
    ".pptx"     -> Just "pptx"
    ".roff"     -> Just "ms"
    ".rst"      -> Just "rst"
    ".rtf"      -> Just "rtf"
    ".s5"       -> Just "s5"
    ".t2t"      -> Just "t2t"
    ".tei"      -> Just "tei"
    ".tei.xml"  -> Just "tei"
    ".tex"      -> Just "latex"
    ".texi"     -> Just "texinfo"
    ".texinfo"  -> Just "texinfo"
    -- ".text"     -> Just "markdown"
    ".text"     -> Just "gfm"
    ".textile"  -> Just "textile"
    -- ".txt"      -> Just "markdown"
    ".txt"      -> Just "gfm"
    -- ".wiki"     -> Just "mediawiki"
    ".wiki"     -> Just "tracwiki"
    ".xhtml"    -> Just "html"
    ".ipynb"    -> Just "ipynb"
    ['.',y]     | y `elem` ['1'..'9'] -> Just "man"
    _           -> Nothing
