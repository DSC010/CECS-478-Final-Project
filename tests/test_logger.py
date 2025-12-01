from telogs import TELogger, verify

def test_happy_path(tmp_path):
    path = tmp_path / "happy.log"
    logger = TELogger(str(path), secret="s3cr3t")
    logger.write("INFO", "one")
    logger.write("INFO", "two")
    ok, idx, _ = verify(str(path), secret="s3cr3t")
    assert ok
    assert idx == 1

def test_corruption_detected(tmp_path):
    path = tmp_path / "bad.log"
    logger = TELogger(str(path), secret="s3cr3t")
    logger.write("INFO", "one")
    logger.write("INFO", "two")
    lines = path.read_text().splitlines()
    lines[1] = lines[1].replace("two", "TWO")
    path.write_text("\n".join(lines))
    ok, idx, reason = verify(str(path), secret="s3cr3t")
    assert not ok
    assert idx == 1

def test_wrong_secret(tmp_path):
    path = tmp_path / "wrong_secret.log"
    logger = TELogger(str(path), secret="A")
    logger.write("INFO", "one")
    ok, _, _ = verify(str(path), secret="B")
    assert not ok