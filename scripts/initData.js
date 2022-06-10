const { BaseModule, readFile, writeFile } = require("./module/baseModule")

class Main extends BaseModule {
  static async main() {
    const instance = new Main()
    if (!(await instance.initialize())) {
      return
    }
    await instance.start()
  }

  async run() {
    this.processFilesModule()
  }

  async processFilesModule() {
    const fileItems = this.config.initData.Files
    for (let fileItem of fileItems) {
      const fileContent = await readFile(fileItem.path)
      const content = await this.processData(fileContent, fileItem.data)

      if (!fileItem.readonly) {
        await writeFile(fileItem.path, content)
      } else {
        console.log(content)
      }
    }
  }

  async processData(content, dataItems) {
    for (let dataItem of dataItems) {
      const repalceValue = dataItem.value[this.chainId]
      if (!repalceValue) {
        continue
      }
      const reg = new RegExp(dataItem.keydata, "gm")
      content = await content.toString().replace(reg, (match, replacePath) => {
        console.log(match, replacePath, repalceValue)
        return match.replace(replacePath, repalceValue)
      })
    }
    return content
  }
  // 这个函数还没用使用过
  async processFileData(fileName, repalceValue, readonly = false) {
    const fileContent = await readFile(fileName)
    fileContent = fileContent.replace(REGEX, (match, replacePath) => {
      return match.replace(replacePath, repalceValue)
    })
    if (!readonly) {
      await writeFile(fileName, fileContent)
    }
  }
}

Main.main()
