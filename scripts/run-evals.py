#!/usr/bin/env python3
import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PACKAGE_ROOT = os.path.dirname(SCRIPT_DIR)
os.chdir(PACKAGE_ROOT)

ANY_TYPE_PATTERN = re.compile(
    r"(:\s*any\b|as\s+any\b|<any>|any\[\]|Array<\s*any\s*>)"
)


def load_test_suite():
    eval_path = os.path.join("evals", "test-suite.json")
    if not os.path.exists(eval_path):
        print(f"[错误] 未找到测试套件文件: {os.path.abspath(eval_path)}")
        sys.exit(1)
    with open(eval_path, "r", encoding="utf-8") as handle:
        return json.load(handle)


def load_response(response_dir, case_id):
    response_path = os.path.join(response_dir, f"{case_id}.txt")
    if not os.path.exists(response_path):
        return None, response_path
    with open(response_path, "r", encoding="utf-8") as handle:
        return handle.read(), response_path


def assert_case(case, output):
    assertion_type = case["assertion_type"]
    if assertion_type == "no_any_type":
        has_unknown = "unknown" in output
        has_any = ANY_TYPE_PATTERN.search(output) is not None
        return has_unknown and not has_any
    if assertion_type == "contains_all":
        phrases = case.get("required_phrases", [])
        return all(phrase in output for phrase in phrases)
    return False


def run_evals():
    print("=== 开始执行 AI 工程行为评测 (Eval Runner) ===")
    print(f"[信息] 当前测试基准目录: {os.getcwd()}")
    print("[信息] 本脚本只检查真实模型输出文件，不生成、不模拟通过结果。")

    suite = load_test_suite()
    response_dir = suite.get("response_dir", "evals/responses")
    test_cases = suite.get("test_cases", [])

    passed_count = 0
    failed_count = 0

    for case in test_cases:
        case_id = case["id"]
        print(f"\n[运行测试] {case_id}: {case['description']}")
        print(f"  Prompt: {case['prompt']}")

        output, response_path = load_response(response_dir, case_id)
        if output is None:
            print(f"  [失败] 缺少真实输出文件: {response_path}")
            failed_count += 1
            continue

        if assert_case(case, output):
            print(f"  [通过] 测试 {case_id} 符合工程预期。")
            passed_count += 1
        else:
            print(f"  [失败] 测试 {case_id} 未通过断言验证: {response_path}")
            failed_count += 1

    print("\n=== 测试报告总结 ===")
    print(f"总计用例: {passed_count + failed_count} | 通过: {passed_count} | 失败: {failed_count}")

    if failed_count > 0:
        print("[说明] 将真实模型回复保存为 evals/responses/<用例id>.txt 后重新运行。")
        sys.exit(1)

    print("=== 所有已提供的真实输出均通过断言。 ===")


if __name__ == "__main__":
    run_evals()
