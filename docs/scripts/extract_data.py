import os
from kaggle.api.kaggle_api_extended import KaggleApi


def download_kaggle_dataset(
    dataset_slug: str,
    download_path: str = "data/raw"
) -> None:
    """
    Download and extract a Kaggle dataset.

    Parameters
    ----------
    dataset_slug : str
        Kaggle dataset identifier, e.g.
        'akrambelha/synthetic-banking-dataset-csv-sql-sqlite'

    download_path : str
        'data/raw'
    """

    os.makedirs(download_path, exist_ok=True)

    # Initialize and authenticate Kaggle API
    api = KaggleApi()
    api.authenticate()

    print(f"Starting download for: {dataset_slug}")

    api.dataset_download_files(
        dataset_slug,
        path=download_path,
        unzip=True
    )

    print(
        f"Success! Dataset downloaded and extracted to: "
        f"{os.path.abspath(download_path)}"
    )


if __name__ == "__main__":

    DATASET = "akrambelha/synthetic-banking-dataset-csv-sql-sqlite"

    download_kaggle_dataset(
        DATASET,
        download_path="data/raw"
    )