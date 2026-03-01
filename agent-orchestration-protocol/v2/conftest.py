"""
AOP V2 — pytest configuration.

Adds v2/core/ to sys.path so tests can import modules directly.
"""
import sys
from pathlib import Path

# Ensure v2/core/ is on the path for all tests
sys.path.insert(0, str(Path(__file__).parent / "core"))
