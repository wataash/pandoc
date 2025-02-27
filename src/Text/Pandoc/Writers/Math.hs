{-# LANGUAGE Strict #-}
{-# LANGUAGE StrictData #-}

{-# LANGUAGE NoImplicitPrelude #-}
module Text.Pandoc.Writers.Math
  ( texMathToInlines
  , convertMath
  , defaultMathJaxURL
  , defaultKaTeXURL
  )
where

import Prelude
import Text.Pandoc.Class
import Text.Pandoc.Definition
import Text.Pandoc.Logging
import Text.TeXMath (DisplayType (..), Exp, readTeX, writePandoc)

-- | Converts a raw TeX math formula to a list of 'Pandoc' inlines.
-- Defaults to raw formula between @$@ or @$$@ characters if entire formula
-- can't be converted.
texMathToInlines :: PandocMonad m
                 => MathType
                 -> String    -- ^ String to parse (assumes @'\n'@ line endings)
                 -> m [Inline]
texMathToInlines mt inp = do
  res <- convertMath writePandoc mt inp
  case res of
       Right (Just ils)  -> return ils
       Right Nothing   -> do
         report $ CouldNotConvertTeXMath inp ""
         return [mkFallback mt inp]
       Left il           -> return [il]

mkFallback :: MathType -> String -> Inline
mkFallback mt str = Str (delim ++ str ++ delim)
   where delim = case mt of
                      DisplayMath -> "$$"
                      InlineMath  -> "$"

-- | Converts a raw TeX math formula using a writer function,
-- issuing a warning and producing a fallback (a raw string)
-- on failure.
convertMath :: PandocMonad m
            => (DisplayType -> [Exp] -> a) -> MathType -> String
            -> m (Either Inline a)
convertMath writer mt str =
  case writer dt <$> readTeX str of
       Right r  -> return (Right r)
       Left e   -> do
         report $ CouldNotConvertTeXMath str e
         return (Left $ mkFallback mt str)
   where dt = case mt of
                   DisplayMath -> DisplayBlock
                   InlineMath  -> DisplayInline

defaultMathJaxURL :: String
defaultMathJaxURL = "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/"

defaultKaTeXURL :: String
defaultKaTeXURL = "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.9.0/"
