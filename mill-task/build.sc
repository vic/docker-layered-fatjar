// -*- scala -*-

import mill._
import scalalib._

object layered extends ScalaModule {
  override def scalaVersion = BuildInfo.scalaVersion
  override def ivyDeps =
    super.ivyDeps() ++ BuildInfo.millEmbeddedDeps.map(Dep.parse)
}
