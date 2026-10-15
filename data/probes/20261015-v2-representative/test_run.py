"""Software-only write-safety check; never launches a benchmark."""
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import run as controls


class DriverTest(unittest.TestCase):
    def test_existing_attempt_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            metadata = root / 'metadata.json'
            original = '{"preserve_first_attempt": true}\n'
            metadata.write_text(original)
            with (mock.patch.object(controls, 'HERE', root),
                  mock.patch.object(sys, 'argv', ['run.py', '/unused/mkl', '/unused/openblas']),
                  self.assertRaisesRegex(RuntimeError, 'control attempt already exists')):
                controls.main()
            self.assertEqual(metadata.read_text(), original)
