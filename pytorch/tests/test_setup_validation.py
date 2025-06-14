"""Validation tests to verify the testing infrastructure is properly set up."""

import sys
from pathlib import Path

import pytest


class TestSetupValidation:
    """Test class to validate the testing infrastructure setup."""

    def test_python_version(self):
        """Test that Python version meets requirements."""
        assert sys.version_info >= (3, 8), "Python 3.8+ is required"

    def test_pytest_installed(self):
        """Test that pytest is properly installed."""
        import pytest
        assert pytest.__version__

    def test_pytest_cov_installed(self):
        """Test that pytest-cov is properly installed."""
        import pytest_cov
        assert pytest_cov.__version__

    def test_pytest_mock_installed(self):
        """Test that pytest-mock is properly installed."""
        import pytest_mock
        assert pytest_mock.__version__

    def test_project_structure(self):
        """Test that the expected project structure exists."""
        project_root = Path(__file__).parent.parent
        
        # Check main Python files exist
        assert (project_root / "main.py").exists()
        assert (project_root / "ITrackerModel.py").exists()
        assert (project_root / "ITrackerData.py").exists()
        
        # Check test directories exist
        assert (project_root / "tests").exists()
        assert (project_root / "tests" / "unit").exists()
        assert (project_root / "tests" / "integration").exists()
        assert (project_root / "tests" / "conftest.py").exists()

    def test_fixtures_available(self, temp_dir, mock_config, sample_image):
        """Test that custom fixtures are available and working."""
        # Test temp_dir fixture
        assert temp_dir.exists()
        assert temp_dir.is_dir()
        
        # Test mock_config fixture
        assert isinstance(mock_config, dict)
        assert "batch_size" in mock_config
        assert "learning_rate" in mock_config
        
        # Test sample_image fixture
        assert sample_image.exists()
        assert sample_image.suffix == ".jpg"

    @pytest.mark.unit
    def test_unit_marker(self):
        """Test that unit test marker works."""
        assert True

    @pytest.mark.integration
    def test_integration_marker(self):
        """Test that integration test marker works."""
        assert True

    @pytest.mark.slow
    def test_slow_marker(self):
        """Test that slow test marker works."""
        assert True

    def test_coverage_configured(self):
        """Test that coverage is properly configured."""
        import coverage
        assert coverage.__version__

    def test_torch_available(self):
        """Test that PyTorch is available."""
        import torch
        assert torch.__version__
        
    def test_numpy_available(self):
        """Test that NumPy is available."""
        import numpy as np
        assert np.__version__
        
    def test_pillow_available(self):
        """Test that Pillow is available."""
        import PIL
        assert PIL.__version__


@pytest.mark.parametrize("fixture_name", [
    "temp_dir",
    "mock_config",
    "sample_image",
    "sample_face_image",
    "sample_eye_images",
    "sample_face_grid",
    "sample_gaze_target",
    "mock_dataset_metadata",
    "mock_model_checkpoint",
    "device",
    "random_seed",
    "mock_dataloader_batch",
])
def test_fixture_exists(fixture_name, request):
    """Test that all expected fixtures are available."""
    assert hasattr(request, "getfixturevalue")
    # This will raise if fixture doesn't exist
    request.getfixturevalue(fixture_name)