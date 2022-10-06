package docker_layered

import mill._
import scalalib._

case class Settings(
  useNixFlake: Boolean = false,
  flakeUrl: String = "github:vic/docker-layered-fatjar",
  size: String = "2M",
  contentRoot: String = "/app",
  main: Option[String] = None,
  layerLimit: Int = 100,
  layerDirs: Seq[String] = Nil,
  layerTopFiles: Boolean = true,
  imageName: Option[String] = None,
  imageTag: Option[String] = None,
  baseImage: String = "gcr.io/distroless/java",
  pushTo: Option[String] = None,
  dockerBuildCli: Seq[String] = Nil
)

object Settings {
  implicit val rw = upickle.default.macroRW[Settings]
}

trait DockerLayeredModule extends JavaModule { enclosing =>

  trait DockerLayered extends Module {
    def settings: T[Settings] = T { Settings() }
    def fatjar: T[PathRef] = enclosing.assembly()

    def build: T[PathRef] = T {
      val out = T.ctx().dest / "layers"
      val fat = fatjar()
      val st = settings()
      val cli = cliExecutable() ++ buildImageCliArgs(st, fat.path, out)
      os.proc(cli).call(check = true, stdin = os.Inherit, stdout = os.Inherit, stderr = os.Inherit)
      fat
    }

    def push: T[PathRef] = T {
      val st = settings()
      val fat = build()
      val local = localImage(st) match {
        case None => throw new Exception("Expected dockerLayered setting: imageName to be set.")
        case Some(x) => x
      }
      val remote = st.pushTo match {
        case None => throw new Exception("Expected dockerLayered setting: pushTo to be set.")
        case Some(x) => x
      }
      os.proc("docker", "push", local, remote).call(
        check = true, stdin = os.Inherit, stdout = os.Inherit, stderr = os.Inherit
      )
      fat
    }

    private def localImage(s: Settings): Option[String] =
      (s.imageName.toSeq ++ s.imageTag.toSeq) match {
        case s if s.nonEmpty => Some(s.mkString(":"))
        case _ => None
      }

    private def cliExecutable: T[Seq[String]] = T {
      val st = settings()
      val local = Seq("layers-from-fatjar")
      val flake = Seq("nix", "run", st.flakeUrl, "--")
      if (st.useNixFlake) flake else local
    }

    private def buildImageCliArgs(st: Settings, fatjar: os.Path, out: os.Path): Seq[String] = {
      Seq[Seq[String]](
        Seq(
          "--docker-build",
          fatjar.toString,
          out.toString,
          "--rm",
          "--size", st.size.toString,
          "--content", st.contentRoot,
          "--limit", st.layerLimit.toString
        ),
        st.main.toSeq.flatMap(s => Seq("--main", s)),
        st.layerDirs.flatMap(s => Seq("--add-layer", s)),
        Option.when(st.layerTopFiles)("--top-layer").toSeq,
        Seq("--"),
        localImage(st).toSeq.flatMap(s => Seq("--tag", s)),
        st.dockerBuildCli
      ).flatten
    }
  }

  object dockerLayered extends DockerLayered

}
