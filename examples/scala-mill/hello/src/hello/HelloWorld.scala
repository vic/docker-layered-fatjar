package hello

import zio._

object HelloWorld extends ZIOAppDefault {
  override val run = Console.printLine("Hello World")
}
