{-# LANGUAGE Strict #-}
{-# LANGUAGE StrictData #-}

{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE CPP                        #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- |
   Module      : Text.Pandoc.Translations
   Copyright   : Copyright (C) 2017-2019 John MacFarlane
   License     : GNU GPL, version 2 or above

   Maintainer  : John MacFarlane <jgm@berkeley.edu>
   Stability   : alpha
   Portability : portable

Data types for localization.

Translations are stored in @data/translations/langname.trans@,
where langname can be the full BCP47 language specifier, or
just the language part.  File format is:

> # A comment, ignored
> Figure: Figura
> Index: Indeksi

-}
module Text.Pandoc.Translations (
                           Term(..)
                         , Translations
                         , lookupTerm
                         , readTranslations
                         )
where
import Prelude
import Data.Aeson.Types (Value(..), FromJSON(..))
import qualified Data.Aeson.Types as Aeson
import qualified Data.HashMap.Strict as HM
import qualified Data.Map as M
import Data.Text as T
import qualified Data.YAML as YAML
import GHC.Generics (Generic)
import Text.Pandoc.Shared (safeRead)
import qualified Text.Pandoc.UTF8 as UTF8

data Term =
    Abstract
  | Appendix
  | Bibliography
  | Cc
  | Chapter
  | Contents
  | Encl
  | Figure
  | Glossary
  | Index
  | Listing
  | ListOfFigures
  | ListOfTables
  | Page
  | Part
  | Preface
  | Proof
  | References
  | See
  | SeeAlso
  | Table
  | To
  deriving (Show, Eq, Ord, Generic, Enum, Read)

newtype Translations = Translations (M.Map Term String)
        deriving (Show, Generic, Semigroup, Monoid)

instance FromJSON Term where
  parseJSON (String t) = case safeRead (T.unpack t) of
                               Just t' -> pure t'
                               Nothing -> fail $ "Invalid Term name " ++
                                                 show t
  parseJSON invalid = Aeson.typeMismatch "Term" invalid

instance YAML.FromYAML Term where
  parseYAML (YAML.Scalar (YAML.SStr t)) =
                         case safeRead (T.unpack t) of
                               Just t' -> pure t'
                               Nothing -> fail $ "Invalid Term name " ++
                                                 show t
  parseYAML invalid = YAML.typeMismatch "Term" invalid

instance FromJSON Translations where
  parseJSON (Object hm) = do
    xs <- mapM addItem (HM.toList hm)
    return $ Translations (M.fromList xs)
    where addItem (k,v) =
            case safeRead (T.unpack k) of
                 Nothing -> fail $ "Invalid Term name " ++ show k
                 Just t  ->
                   case v of
                        (String s) -> return (t, T.unpack $ T.strip s)
                        inv        -> Aeson.typeMismatch "String" inv
  parseJSON invalid = Aeson.typeMismatch "Translations" invalid

instance YAML.FromYAML Translations where
  parseYAML = YAML.withMap "Translations" $
    \tr -> Translations .M.fromList <$> mapM addItem (M.toList tr)
   where addItem (n@(YAML.Scalar (YAML.SStr k)), v) =
            case safeRead (T.unpack k) of
                 Nothing -> YAML.typeMismatch "Term" n
                 Just t  ->
                   case v of
                        (YAML.Scalar (YAML.SStr s)) ->
                          return (t, T.unpack (T.strip s))
                        n' -> YAML.typeMismatch "String" n'
         addItem (n, _) = YAML.typeMismatch "String" n

lookupTerm :: Term -> Translations -> Maybe String
lookupTerm t (Translations tm) = M.lookup t tm

readTranslations :: String -> Either String Translations
readTranslations s =
  case YAML.decodeStrict $ UTF8.fromString s of
       Left err'   -> Left err'
       Right (t:_) -> Right t
       Right []    -> Left "empty YAML document"
