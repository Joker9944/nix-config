_:
{
  scheme,
  accents,
  accent ? "blue",
}:
import ./templates/gtk4.css.nix scheme.palette accents accent
