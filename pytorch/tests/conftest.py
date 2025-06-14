"""Shared pytest fixtures and configuration for iTracker tests."""

import os
import shutil
import tempfile
from pathlib import Path
from typing import Generator

import numpy as np
import pytest
import torch
from PIL import Image


@pytest.fixture
def temp_dir() -> Generator[Path, None, None]:
    """Create a temporary directory for test files."""
    temp_path = tempfile.mkdtemp()
    yield Path(temp_path)
    shutil.rmtree(temp_path)


@pytest.fixture
def mock_config() -> dict:
    """Provide a mock configuration dictionary for testing."""
    return {
        "batch_size": 16,
        "epochs": 10,
        "learning_rate": 0.001,
        "momentum": 0.9,
        "weight_decay": 0.0001,
        "print_freq": 10,
        "eval_freq": 500,
        "save_freq": 1000,
        "resume": "",
        "start_epoch": 0,
        "workers": 4,
        "pretrained": False,
    }


@pytest.fixture
def sample_image(temp_dir: Path) -> Path:
    """Create a sample image for testing."""
    img_path = temp_dir / "sample_image.jpg"
    img_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
    img = Image.fromarray(img_array)
    img.save(img_path)
    return img_path


@pytest.fixture
def sample_face_image(temp_dir: Path) -> Path:
    """Create a sample face image for testing."""
    img_path = temp_dir / "face_image.jpg"
    img_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
    img = Image.fromarray(img_array)
    img.save(img_path)
    return img_path


@pytest.fixture
def sample_eye_images(temp_dir: Path) -> tuple[Path, Path]:
    """Create sample left and right eye images for testing."""
    left_eye_path = temp_dir / "left_eye.jpg"
    right_eye_path = temp_dir / "right_eye.jpg"
    
    for eye_path in [left_eye_path, right_eye_path]:
        img_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
        img = Image.fromarray(img_array)
        img.save(eye_path)
    
    return left_eye_path, right_eye_path


@pytest.fixture
def sample_face_grid() -> torch.Tensor:
    """Create a sample face grid tensor for testing."""
    return torch.randn(1, 1, 25, 25)


@pytest.fixture
def sample_gaze_target() -> torch.Tensor:
    """Create a sample gaze target tensor for testing."""
    return torch.randn(1, 2)


@pytest.fixture
def mock_dataset_metadata() -> dict:
    """Provide mock dataset metadata for testing."""
    return {
        "num_samples": 1000,
        "image_size": (224, 224),
        "face_grid_size": (25, 25),
        "mean_face": np.random.randn(224, 224, 3),
        "mean_left_eye": np.random.randn(224, 224, 3),
        "mean_right_eye": np.random.randn(224, 224, 3),
        "std_face": np.ones((224, 224, 3)),
        "std_left_eye": np.ones((224, 224, 3)),
        "std_right_eye": np.ones((224, 224, 3)),
    }


@pytest.fixture
def mock_model_checkpoint(temp_dir: Path) -> Path:
    """Create a mock model checkpoint for testing."""
    checkpoint_path = temp_dir / "checkpoint.pth.tar"
    checkpoint = {
        "epoch": 5,
        "arch": "itracker",
        "state_dict": {},
        "best_prec1": 0.95,
        "optimizer": {},
    }
    torch.save(checkpoint, checkpoint_path)
    return checkpoint_path


@pytest.fixture
def device() -> torch.device:
    """Return the appropriate device for testing (CPU or CUDA if available)."""
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")


@pytest.fixture
def random_seed() -> int:
    """Set and return a fixed random seed for reproducible tests."""
    seed = 42
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(seed)
    return seed


@pytest.fixture(autouse=True)
def cleanup_cuda():
    """Automatically cleanup CUDA cache after each test."""
    yield
    if torch.cuda.is_available():
        torch.cuda.empty_cache()


@pytest.fixture
def mock_dataloader_batch() -> dict:
    """Create a mock batch of data as would be returned by a DataLoader."""
    batch_size = 4
    return {
        "face": torch.randn(batch_size, 3, 224, 224),
        "left_eye": torch.randn(batch_size, 3, 224, 224),
        "right_eye": torch.randn(batch_size, 3, 224, 224),
        "face_grid": torch.randn(batch_size, 1, 25, 25),
        "gaze": torch.randn(batch_size, 2),
    }


def pytest_configure(config):
    """Configure pytest with custom settings."""
    config.addinivalue_line(
        "markers", "unit: mark test as a unit test"
    )
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )


def pytest_collection_modifyitems(config, items):
    """Modify test collection to add markers based on test location."""
    for item in items:
        if "unit" in str(item.fspath):
            item.add_marker(pytest.mark.unit)
        elif "integration" in str(item.fspath):
            item.add_marker(pytest.mark.integration)