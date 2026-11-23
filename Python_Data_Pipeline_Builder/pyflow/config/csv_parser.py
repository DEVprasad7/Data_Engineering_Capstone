
import pandas as pd
from pathlib import Path


class CSVParser:
    """Parse CSV files into Pandas DataFrames."""

    def __init__(self, file_path: str | Path) -> None:
        self.file_path = Path(file_path)

        if not self.file_path.is_file():
            raise FileNotFoundError(
                f"File does not exist: {self.file_path}"
            )

        self.data = self._load()

    def _load(self) -> pd.DataFrame:
        """Read JSON file into a DataFrame."""
        return pd.read_csv(self.file_path, encoding="utf-8")

    def show(self) -> pd.DataFrame:
        """Return the parsed data."""
        return self.data
