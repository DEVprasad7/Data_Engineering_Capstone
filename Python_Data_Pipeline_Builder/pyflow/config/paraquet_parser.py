
import pyarrow.parquet as pq
from pathlib import Path


class ParaquetParser:
    """Parse CSV files into Pandas DataFrames."""

    def __init__(self, file_path: str | Path) -> None:
        self.file_path = Path(file_path)

        if not self.file_path.is_file():
            raise FileNotFoundError(
                f"File does not exist: {self.file_path}"
            )

        self.data = self._load()

    def _load(self):
        """Read JSON file into a DataFrame."""
        data = pq.read_table(self.file_path)
        return data.to_pandas()

    def show(self):
        """Return the parsed data."""
        return self.data
