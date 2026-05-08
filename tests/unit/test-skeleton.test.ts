// Harness 项目测试骨架
// TDD 原则：测试骨架存在，逻辑占位（RED 状态）
// Coder 负责逐个实现让测试变绿

import { describe, it, expect } from 'vitest'
import { readFileSync, existsSync, readdirSync } from 'fs'
import { join } from 'path'

const ROOT = '/Users/ping/WorkBuddy/harness'

// ─── README 内容完整性测试 ─────────────────────────────────────────

describe('README 内容完整性', () => {
  const readmePath = join(ROOT, 'README.md')

  it('README 包含项目概述章节', () => {
    const content = readFileSync(readmePath, 'utf-8')
    expect(content.includes('## 概述')).toBe(true)
  })

  it('README 包含快速开始指南', () => {
    const content = readFileSync(readmePath, 'utf-8')
    expect(content.includes('快速开始') || content.includes('快速入门')).toBe(true)
  })

  it('README 包含项目结构说明', () => {
    const content = readFileSync(readmePath, 'utf-8')
    expect(content.includes('skills/') && content.includes('web-harness')).toBe(true)
  })

  it('README 包含 Git 仓库链接', () => {
    const content = readFileSync(readmePath, 'utf-8')
    expect(content.includes('github.com/fingermelody/harness')).toBe(true)
  })
})

// ─── Skills 目录结构测试 ───────────────────────────────────────────

describe('Skills 目录结构', () => {
  const skillsDir = join(ROOT, 'skills')
  const webHarnessDir = join(skillsDir, 'web-harness')
  const refsDir = join(webHarnessDir, 'references')

  const requiredRefs = [
    'agents.md',
    'state-machine.md',
    'evaluation.md',
    'verification.md',
    'monitoring.md',
    'memory.md',
    'team-engine.md',
    'manual.md',
  ]

  it('web-harness 技能目录存在', () => {
    expect(existsSync(webHarnessDir)).toBe(true)
  })

  it('web-harness 包含 SKILL.md', () => {
    expect(existsSync(join(webHarnessDir, 'SKILL.md'))).toBe(true)
  })

  it('web-harness 包含所有 reference 文件', () => {
    for (const ref of requiredRefs) {
      expect(existsSync(join(refsDir, ref))).toBe(true)
    }
  })

  it('state-machine.md 包含 TDD 相关状态', () => {
    const content = readFileSync(join(refsDir, 'state-machine.md'), 'utf-8')
    const hasStates = ['TEST-PLAN', 'DEPLOY-TEST', 'DEPLOY-PROD'].every(s => content.includes(s))
    expect(hasStates).toBe(true)
  })

  it('verification.md 包含测试环境配置', () => {
    const content = readFileSync(join(refsDir, 'verification.md'), 'utf-8')
    const hasEnv = content.includes('test') && content.includes('production')
    expect(hasEnv).toBe(true)
  })
})

// ─── Git 配置测试 ─────────────────────────────────────────────────

describe('Git 配置', () => {
  it('存在 .gitignore 文件', () => {
    expect(existsSync(join(ROOT, '.gitignore'))).toBe(true)
  })

  it('.gitignore 忽略 .workbuddy/', () => {
    const content = readFileSync(join(ROOT, '.gitignore'), 'utf-8')
    expect(content.includes('.workbuddy/')).toBe(true)
  })
})
